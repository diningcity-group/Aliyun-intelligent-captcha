# frozen_string_literal: true

require_relative "aliyun_intelligent_captcha/client"
require_relative "aliyun_intelligent_captcha/configuration"
require_relative "aliyun_intelligent_captcha/error"
require_relative "aliyun_intelligent_captcha/result"
require_relative "aliyun_intelligent_captcha/version"

require_relative "aliyun_intelligent_captcha/railtie" if defined?(Rails::Railtie)

module AliyunIntelligentCaptcha
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def client
      @client ||= Client.new(**configuration.to_h)
    end

    def reset_client!
      @client = nil
    end

    def verify(...)
      client.verify(...)
    end
  end
end
