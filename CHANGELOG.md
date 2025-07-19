# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-07-19

### Added
- Initial release of Hmibo gem
- Base service class pattern for clean business logic organization
- Structured error handling with automatic logging via LoggerHead
- Result pattern with success/failure states and data
- BulkCreation service for bulk record operations with individual error tracking
- Test helpers for RSpec integration
- Comprehensive test coverage
- Documentation and examples

### Features
- Simple, lightweight service object pattern
- Consistent error collection with flexible formats
- Automatic exception logging with contextual information
- Support for bulk operations with per-record error tracking
- Rails-friendly with minimal dependencies
- Clean API: `SomeService.call(params)`
- Error interface: `result.errors?`, `result.errors`, `result.data`