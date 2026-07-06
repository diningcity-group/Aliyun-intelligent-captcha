# frozen_string_literal: true

require "rails/railtie"

require_relative "configuration"
require_relative "rails/controller_helpers"

module AliyunIntelligentCaptcha
  class Railtie < ::Rails::Railtie
    config.aliyun_intelligent_captcha = Configuration.new

    initializer "aliyun_intelligent_captcha.configure" do |app|
      AliyunIntelligentCaptcha.configure do |config|
        app.config.aliyun_intelligent_captcha.to_h.each do |key, value|
          config.public_send("#{key}=", value)
        end
      end
      AliyunIntelligentCaptcha.reset_client!
    end
  end
end
