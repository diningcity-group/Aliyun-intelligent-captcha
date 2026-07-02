# frozen_string_literal: true

require "test_helper"

class AliyunIntelligentCaptchaTest < Minitest::Test
  FakeResponse = Struct.new(:code, :body)

  def test_verify_posts_signed_normalized_payload
    captured = {}
    client = AliyunIntelligentCaptcha::Client.new(
      access_key_id: "ak",
      access_key_secret: "secret",
      scene_id: "scene",
      http_client: lambda do |request, uri|
        captured[:uri] = uri
        captured[:request] = request
        FakeResponse.new("200", JSON.generate("VerifyResult" => true, "RequestId" => "rid"))
      end
    )

    result = client.verify(captcha_verify_param: "token", remote_ip: "127.0.0.1")

    assert result.passed?
    assert_equal "rid", result.request_id
    assert_equal "captcha.cn-shanghai.aliyuncs.com", captured[:uri].host
    assert_equal "VerifyIntelligentCaptcha", captured[:request]["x-acs-action"]
    assert_equal "2023-03-05", captured[:request]["x-acs-version"]
    assert_match(/\AACS3-HMAC-SHA256 Credential=ak,/, captured[:request]["Authorization"])
    assert_equal(
      { "CaptchaVerifyParam" => "token", "RemoteIp" => "127.0.0.1", "SceneId" => "scene" },
      JSON.parse(captured[:request].body)
    )
  end

  def test_missing_credentials_raise_configuration_error
    client = AliyunIntelligentCaptcha::Client.new(access_key_id: nil, access_key_secret: nil)

    assert_raises(AliyunIntelligentCaptcha::ConfigurationError) do
      client.verify(captcha_verify_param: "token")
    end
  end
end
