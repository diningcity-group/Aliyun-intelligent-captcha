# frozen_string_literal: true

module AliyunIntelligentCaptcha
  class Error < StandardError; end
  class ConfigurationError < Error; end
  class RequestError < Error; end
  class ResponseError < Error; end
end
