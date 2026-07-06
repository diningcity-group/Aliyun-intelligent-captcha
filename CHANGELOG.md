# Changelog

All notable changes to this project will be documented in this file.

## [0.1.1] - 2026-07-06

### Fixed
- Fix Rails railtie constant resolution by inheriting from `::Rails::Railtie` to avoid namespace collision with `AliyunIntelligentCaptcha::Rails`.

## [0.1.0] - 2026-07-06

### Added
- Initial release.
- Ruby client to call Alibaba Cloud `VerifyIntelligentCaptcha` API.
- Rails integration via railtie and controller helpers.
- Request signing with ACS3-HMAC-SHA256 and Net::HTTP transport.
