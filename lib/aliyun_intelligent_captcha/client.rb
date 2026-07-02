# frozen_string_literal: true

require "base64"
require "json"
require "net/http"
require "openssl"
require "securerandom"
require "time"
require "uri"

require_relative "configuration"
require_relative "error"
require_relative "result"

module AliyunIntelligentCaptcha
  class Client
    ACTION = "VerifyIntelligentCaptcha"
    CONTENT_TYPE = "application/json; charset=utf-8"
    SIGNATURE_ALGORITHM = "ACS3-HMAC-SHA256"

    def initialize(access_key_id:,
                   access_key_secret:,
                   endpoint: Configuration::DEFAULT_ENDPOINT,
                   api_version: Configuration::DEFAULT_API_VERSION,
                   scene_id: nil,
                   open_timeout: Configuration::DEFAULT_OPEN_TIMEOUT,
                   read_timeout: Configuration::DEFAULT_READ_TIMEOUT,
                   logger: nil,
                   http_client: nil)
      @access_key_id = access_key_id
      @access_key_secret = access_key_secret
      @endpoint = endpoint
      @api_version = api_version
      @scene_id = scene_id
      @open_timeout = open_timeout
      @read_timeout = read_timeout
      @logger = logger
      @http_client = http_client
    end

    def verify(captcha_verify_param:, scene_id: @scene_id, **extra)
      ensure_configured!

      payload = normalize_payload(
        extra.merge(captcha_verify_param: captcha_verify_param, scene_id: scene_id).compact
      )
      response = perform_request(payload)
      Result.new(body: parse_response(response.body), status: response.code)
    end

    private

    def ensure_configured!
      raise ConfigurationError, "access_key_id is required" if blank?(@access_key_id)
      raise ConfigurationError, "access_key_secret is required" if blank?(@access_key_secret)
    end

    def perform_request(payload)
      uri = URI::HTTPS.build(host: @endpoint, path: "/")
      body = JSON.generate(payload)
      request = Net::HTTP::Post.new(uri)
      request.body = body
      signed_headers(body).each { |key, value| request[key] = value }

      response = @http_client ? @http_client.call(request, uri) : net_http_request(uri, request)
      validate_response!(response)
      response
    rescue Timeout::Error, SocketError, SystemCallError, OpenSSL::SSL::SSLError => error
      @logger&.warn("[aliyun_intelligent_captcha] request failed: #{error.class}: #{error.message}")
      raise RequestError, error.message
    end

    def net_http_request(uri, request)
      Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: @open_timeout, read_timeout: @read_timeout) do |http|
        http.request(request)
      end
    end

    def signed_headers(body)
      content_sha256 = sha256_hex(body)
      headers = {
        "host" => @endpoint,
        "content-type" => CONTENT_TYPE,
        "x-acs-action" => ACTION,
        "x-acs-version" => @api_version,
        "x-acs-date" => Time.now.utc.iso8601,
        "x-acs-signature-nonce" => SecureRandom.uuid,
        "x-acs-content-sha256" => content_sha256
      }

      headers.merge("Authorization" => authorization(headers, content_sha256))
    end

    def authorization(headers, content_sha256)
      signed_header_names = headers.keys.map(&:downcase).sort
      canonical_headers = signed_header_names.map { |name| "#{name}:#{headers.fetch(name)}\n" }.join
      signed_headers = signed_header_names.join(";")
      canonical_request = [
        "POST",
        "/",
        "",
        canonical_headers,
        signed_headers,
        content_sha256
      ].join("\n")
      string_to_sign = "#{SIGNATURE_ALGORITHM}\n#{sha256_hex(canonical_request)}"
      signature = OpenSSL::HMAC.hexdigest("SHA256", @access_key_secret, string_to_sign)

      "#{SIGNATURE_ALGORITHM} Credential=#{@access_key_id},SignedHeaders=#{signed_headers},Signature=#{signature}"
    end

    def validate_response!(response)
      return if response.code.to_i.between?(200, 299)

      raise ResponseError, "Aliyun captcha API returned HTTP #{response.code}: #{response.body}"
    end

    def parse_response(body)
      JSON.parse(body)
    rescue JSON::ParserError => error
      raise ResponseError, "invalid JSON response: #{error.message}"
    end

    def normalize_payload(payload)
      payload.each_with_object({}) do |(key, value), normalized|
        normalized[camelize(key.to_s)] = value
      end
    end

    def camelize(value)
      value.split("_").map(&:capitalize).join
    end

    def sha256_hex(value)
      OpenSSL::Digest::SHA256.hexdigest(value)
    end

    def blank?(value)
      value.nil? || value.to_s.strip.empty?
    end
  end
end
