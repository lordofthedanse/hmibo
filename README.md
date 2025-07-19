# Hmibo

**How May I Be Of service!** 

Hmibo is a lightweight Ruby gem that provides simple, consistent patterns for service objects. Inspired by personal patterns, it offers structured error handling and logging for business logic in your Rails applications.

## Features

- **Simple Base Service Class**: Clean pattern following personal conventions
- **Structured Error Logging**: Integrated with LoggerHead for contextual error logging
- **Consistent Error Handling**: Structured error collection with flexible formats
- **Bulk Operations**: Specialized service for bulk record creation with individual error tracking
- **Rails Testing Helpers**: RSpec helpers for easy service testing
- **Minimal Dependencies**: Uses LoggerHead for enhanced error logging (works great with Rails 7.1+)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hmibo'
```

And then execute:

```bash
$ bundle install
```

## Usage

### Basic Service Object

```ruby
class CreateUserService < Hmibo::Base
  def initialize(name:, email:, role: 'user')
    @name = name
    @email = email
    @role = role
    super()
  end

  private

  attr_reader :name, :email, :role

  def perform
    add_error("Name is required") if name.blank?
    add_error("Email is required") if email.blank?
    add_error("Email format is invalid") unless valid_email?
    
    return self if errors?

    user = User.create!(name: name, email: email, role: role)
    @data = user
    self
  end

  def valid_email?
    email.match?(/\A[^@\s]+@[^@\s]+\z/)
  end
end

# Usage
result = CreateUserService.call(name: "John Doe", email: "john@example.com")

if result.errors?
  puts "Errors: #{result.errors.map { |e| e[:message] }.join(', ')}"
else
  puts "User created: #{result.data.name}"
end
```

### Bulk Creation Service

```ruby
# Create multiple records with error handling
params = [
  { name: "John", email: "john@example.com", client_side_id: "temp-1" },
  { name: "Jane", email: "invalid-email", client_side_id: "temp-2" },
  { name: "Bob", email: "bob@example.com", client_side_id: "temp-3" }
]

result = Hmibo::BulkCreation.call(params, User)

if result.errors?
  result.errors.each do |error|
    puts "Error for #{error[:id]}: #{error[:message]}"
  end
else
  puts "All #{result.data.length} users created successfully"
end
```

## Service Response

Every service returns itself with the following interface:

```ruby
result = SomeService.call(params)

result.errors?      # => true/false if there are errors
result.data         # => Any data set by the service
result.errors       # => Array of error hashes: [{message: "...", code: 422, id: nil}]
```

## Error Handling

Services provide structured error handling with automatic logging:

```ruby
class ExampleService < Hmibo::Base
  private

  def perform
    # Add individual errors
    add_error("Something went wrong")
    
    # Errors are automatically logged with context using LoggerHead
    return self if errors?

    @data = { success: true }
    self
  end
end
```

### Automatic Error Logging

Hmibo integrates with [LoggerHead](https://github.com/lordofthedanse/logger_head) to provide structured error logging with context:

```ruby
class CreateUserService < Hmibo::Base
  def perform
    # Any unhandled exceptions are automatically logged with context
    raise StandardError, "Database connection failed"
  end
end

result = CreateUserService.call
# Automatically logs:
# ERROR -- : There was an error in CreateUserService execution: Database connection failed
# ERROR -- : /path/to/backtrace...
```

### Custom Error Context

You can provide custom context for error logging:

```ruby
class PaymentService < Hmibo::Base
  private

  def perform
    process_payment
  rescue => error
    log_error(error, context: "processing payment for user #{user_id}")
    add_error("Payment processing failed")
    self
  end
end
```

## Exception Classes

Hmibo provides custom exception classes:

- `Hmibo::ServiceError` - Base service error

## Dependencies

Hmibo has one very lightweight dependency:

- [LoggerHead](https://github.com/lordofthedanse/logger_head) - Structured error logging with context

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
