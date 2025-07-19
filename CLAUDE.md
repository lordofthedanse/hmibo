# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Hmibo is a lightweight Ruby gem providing simple, dependency-free service object patterns inspired by DetectionTek conventions. The gem focuses on business logic encapsulation, error handling, and bulk operations for Rails applications.

## Development Commands

- **Run tests**: `rake spec` or `bundle exec rspec`
- **Run linting**: `rake rubocop` or `bundle exec rubocop`
- **Run all checks**: `rake` (runs both tests and rubocop)
- **Build gem**: `rake build`
- **Install gem locally**: `rake install`

## Core Architecture

### Service Object Pattern
All services inherit from `Hmibo::Base` (lib/hmibo/base.rb), which provides:
- Error collection and handling via `@errors` array
- `call` class method for service execution
- Exception handling with `handle_error`
- Logging integration (Rails-aware)

Services implement business logic in the private `perform` method and use:
- `add_error(message, code:, id:)` for error tracking
- `errors?` to check for validation failures

### Result Objects
`Hmibo::Result` (lib/hmibo/result.rb) provides consistent return values with:
- `success?` / `failure?` status methods
- `message`, `data`, and `errors` attributes
- JSON serialization via `to_h` and `to_json`
- Factory methods: `Result.success(message, data)` and `Result.failure(message, errors)`

### Bulk Operations
`Hmibo::BulkCreation` (lib/hmibo/bulk_creation.rb) handles batch record creation:
- Processes arrays of parameters with `client_side_id` tracking
- Individual error tracking per record
- Validation for input parameters and target class

### Test Integration
`Hmibo::TestHelpers` (lib/hmibo/test_helpers.rb) provides RSpec matchers:
- `expect_service_success(service)` - assert successful execution
- `expect_service_failure(service, expected_error_count:)` - assert failure
- `expect_service_error(service, message)` - assert specific error messages
- `expect_service_error_with_attributes(service, attributes)` - assert error structure
- `mock_service` and `stub_service` for test doubles

## File Structure
- `lib/hmibo.rb` - Main entry point and exception classes
- `lib/hmibo/base.rb` - Core service class
- `lib/hmibo/result.rb` - Result object implementation
- `lib/hmibo/bulk_creation.rb` - Bulk operation service
- `lib/hmibo/error.rb` - Custom exception definitions
- `lib/hmibo/concerns/` - Reusable service modules
- `spec/` - RSpec test suite with Rails integration tests

## Testing Approach
- Uses RSpec with custom matchers from TestHelpers
- Rails integration specs in spec/integration/
- Service-specific specs follow naming convention: `service_name_spec.rb`
- Test helpers automatically included via spec_helper.rb configuration