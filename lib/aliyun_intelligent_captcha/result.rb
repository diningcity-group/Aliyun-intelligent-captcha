# frozen_string_literal: true

module AliyunIntelligentCaptcha
  class Result
    attr_reader :body, :status

    def initialize(body:, status:)
      @body = body
      @status = status.to_i
    end

    def passed?
      truthy?(fetch_value("VerifyResult")) ||
        truthy?(fetch_value("Passed")) ||
        truthy?(fetch_value("Result")) ||
        success_code?
    end

    def request_id
      fetch_value("RequestId")
    end

    def code
      fetch_value("Code")
    end

    def message
      fetch_value("Message")
    end

    private

    def fetch_value(key)
      body[key] || body[underscore(key)]
    end

    def underscore(value)
      value.gsub(/([a-z\d])([A-Z])/, "\\1_\\2").downcase
    end

    def success_code?
      code.to_s.casecmp("OK").zero? || code.to_s == "200"
    end

    def truthy?(value)
      value == true || value.to_s.casecmp("true").zero? || value.to_s == "1"
    end
  end
end
