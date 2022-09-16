# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

## [v0.1.0] - 2022-09-16


### Added

- [https://github.com/catawiki/rate-limit/pull/11] `RateLimit::Result` class
- [https://github.com/catawiki/rate-limit/pull/12] `RateLimit::Worker` class
- [https://github.com/catawiki/rate-limit/pull/13] `RateLimit::Config#on_success` and `RateLimit::Config#on_failure`

### Changed

- `RateLimit.throttle` to not accept block
- `RateLimit.throttle` to return `RateLimit::Result` object
- `RateLimit::Throttler` from class to module while moving responsibilities to `RateLimit::Worker` class
- renamed `RateLimit.throttle!` to `RateLimit.throttle_with_block!`
- renamed `RateLimit.throttle_only_failures` to `RateLimit.throttle_only_failures_with_block!`

### Fixed

- [https://github.com/catawiki/rate-limit/issues/7] Symbol topic names does not load the correct limits
- [https://github.com/catawiki/rate-limit/issues/6] Main Module (RateLimit) fails to autoload


## v0.0.1 - 2022-09-09

- Initial gem release

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html

<!-- versions -->

[Unreleased]: https://github.com/catawiki/rate-limit/compare/v0.1.0...HEAD
[v0.1.0]: https://github.com/catawiki/rate-limit/compare/v0.0.1...v0.1.0