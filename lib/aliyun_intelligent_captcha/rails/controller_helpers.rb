# frozen_string_literal: true

module AliyunIntelligentCaptcha
  module Rails
    module ControllerHelpers
      def verify_aliyun_intelligent_captcha(captcha_verify_param, **extra)
        AliyunIntelligentCaptcha.verify(
          captcha_verify_param: captcha_verify_param,
          remote_ip: request.remote_ip,
          **extra
        ).passed?
      end
    end
  end
end
