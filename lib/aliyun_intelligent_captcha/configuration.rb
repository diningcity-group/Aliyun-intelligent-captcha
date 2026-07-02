# frozen_string_literal: true

module AliyunIntelligentCaptcha
  class Configuration
    DEFAULT_ENDPOINT = "captcha.cn-shanghai.aliyuncs.com"
    DEFAULT_API_VERSION = "2023-03-05"
    DEFAULT_OPEN_TIMEOUT = 2
    DEFAULT_READ_TIMEOUT = 5

    attr_accessor :access_key_id,
                  :access_key_secret,
                  :endpoint,
                  :api_version,
                  :scene_id,
                  :open_timeout,
                  :read_timeout,
                  :logger

    def initialize
      @endpoint = DEFAULT_ENDPOINT
      @api_version = DEFAULT_API_VERSION
      @open_timeout = DEFAULT_OPEN_TIMEOUT
      @read_timeout = DEFAULT_READ_TIMEOUT
    end

    def to_h
      {
        access_key_id: access_key_id,
        access_key_secret: access_key_secret,
        endpoint: endpoint,
        api_version: api_version,
        scene_id: scene_id,
        open_timeout: open_timeout,
        read_timeout: read_timeout,
        logger: logger
      }
    end
  end
end
