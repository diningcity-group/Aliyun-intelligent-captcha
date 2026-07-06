# Aliyun Intelligent Captcha

Ruby gem for verifying Alibaba Cloud intelligent captcha tokens with the `VerifyIntelligentCaptcha` OpenAPI.

It has no runtime dependency on the Alibaba Cloud SDK. The client signs requests with Alibaba Cloud ACS3-HMAC-SHA256 and uses Ruby's standard `Net::HTTP`.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## Latest Release

- `0.1.1`
- Fix railtie inheritance to use top-level `::Rails::Railtie`, preventing constant lookup conflicts in Rails apps.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "aliyun_intelligent_captcha"
```

Then run:

```sh
bundle install
```

## Rails Configuration

Create `config/initializers/aliyun_intelligent_captcha.rb`:

```ruby
AliyunIntelligentCaptcha.configure do |config|
  config.access_key_id = ENV.fetch("ALIYUN_ACCESS_KEY_ID")
  config.access_key_secret = ENV.fetch("ALIYUN_ACCESS_KEY_SECRET")
  config.scene_id = ENV["ALIYUN_CAPTCHA_SCENE_ID"]

  # Defaults:
  # config.endpoint = "captcha.cn-shanghai.aliyuncs.com"
  # config.api_version = "2023-03-05"
  # config.open_timeout = 2
  # config.read_timeout = 5
end
```

You can also use Rails config:

```ruby
# config/application.rb
config.aliyun_intelligent_captcha.access_key_id = ENV["ALIYUN_ACCESS_KEY_ID"]
config.aliyun_intelligent_captcha.access_key_secret = ENV["ALIYUN_ACCESS_KEY_SECRET"]
```

## Usage

```ruby
result = AliyunIntelligentCaptcha.verify(
  captcha_verify_param: params[:captcha_verify_param],
  remote_ip: request.remote_ip
)

if result.passed?
  # continue
else
  # reject request
end
```

For Rails controllers:

```ruby
class ApplicationController < ActionController::Base
  include AliyunIntelligentCaptcha::Rails::ControllerHelpers
end

class SessionsController < ApplicationController
  def create
    unless verify_aliyun_intelligent_captcha(params[:captcha_verify_param])
      render status: :unprocessable_entity, json: { error: "captcha_failed" }
      return
    end

    # sign in
  end
end
```

## Custom Fields

Alibaba Cloud may add or rename request fields. Pass additional OpenAPI fields as keyword arguments:

```ruby
AliyunIntelligentCaptcha.verify(
  captcha_verify_param: params[:captcha_verify_param],
  scene_id: "your_scene_id",
  user_id: current_user.id,
  remote_ip: request.remote_ip
)
```

Ruby snake_case keys are converted to Alibaba Cloud CamelCase keys:

```ruby
captcha_verify_param # => CaptchaVerifyParam
remote_ip            # => RemoteIp
```

## Direct Client

```ruby
client = AliyunIntelligentCaptcha::Client.new(
  access_key_id: "...",
  access_key_secret: "...",
  scene_id: "..."
)

client.verify(captcha_verify_param: "...")
```

## Error Handling

Network errors and non-2xx responses raise `AliyunIntelligentCaptcha::Error` subclasses:

```ruby
begin
  result = AliyunIntelligentCaptcha.verify(captcha_verify_param: token)
rescue AliyunIntelligentCaptcha::ConfigurationError, AliyunIntelligentCaptcha::RequestError => error
  Rails.logger.warn("captcha verify failed: #{error.message}")
end
```
