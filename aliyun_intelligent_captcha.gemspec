require_relative "lib/aliyun_intelligent_captcha/version"

Gem::Specification.new do |spec|
  spec.name = "aliyun_intelligent_captcha"
  spec.version = AliyunIntelligentCaptcha::VERSION
  spec.authors = ["ming"]
  spec.email = ["ming@example.com"]

  spec.summary = "Ruby client for Alibaba Cloud VerifyIntelligentCaptcha."
  spec.description = "A small Ruby/Rails friendly gem for verifying Alibaba Cloud intelligent captcha tokens through the VerifyIntelligentCaptcha OpenAPI."
  spec.homepage = "https://github.com/diningcity-group/Aliyun-intelligent-captcha"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.files = Dir["lib/**/*.rb", "README.md", "LICENSE.txt"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
