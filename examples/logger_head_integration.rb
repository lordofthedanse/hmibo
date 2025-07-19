# frozen_string_literal: true

# Example demonstrating LoggerHead integration in Hmibo services
# This example shows how LoggerHead provides structured error logging with context

require_relative "../lib/hmibo"

# Example service that demonstrates LoggerHead integration
class ExampleService < Hmibo::Base
  def initialize(data:)
    @data_input = data
    super()
  end

  private

  attr_reader :data_input

  def perform
    # Validate input
    if data_input.nil?
      add_error("Data cannot be nil")
      return self
    end

    # Simulate some processing that might fail
    if data_input[:name].nil? || data_input[:name].empty?
      add_error("Name is required")
    end

    if data_input[:age] && data_input[:age] < 0
      add_error("Age must be positive")
    end

    return self if errors?

    # Simulate a potential runtime error for demonstration
    if data_input[:name] == "trigger_error"
      raise StandardError, "Simulated processing error"
    end

    @data = { processed: true, name: data_input[:name], age: data_input[:age] }
    self
  end
end

# Example usage with LoggerHead integration
puts "=== LoggerHead Integration in Hmibo Example ==="
puts

# Example 1: Successful execution
puts "1. Successful execution:"
result = ExampleService.call(data: { name: "John", age: 25 })
puts "  Success: #{!result.errors?}"
puts "  Data: #{result.data}"
puts

# Example 2: Validation errors (logged with context)
puts "2. Validation errors:"
result = ExampleService.call(data: { name: "", age: -5 })
puts "  Success: #{!result.errors?}"
puts "  Errors: #{result.errors}"
puts

# Example 3: Runtime exception (logged with LoggerHead)
puts "3. Runtime exception (check logs for LoggerHead output):"
result = ExampleService.call(data: { name: "trigger_error", age: 30 })
puts "  Success: #{!result.errors?}"
puts "  Errors: #{result.errors}"
puts

puts "=== LoggerHead Features ==="
puts "✓ Structured error logging with context"
puts "✓ Automatic backtrace logging"
puts "✓ Service class context included"
puts "✓ Works in Rails and non-Rails environments"
puts "✓ Consistent with DetectionTek logging patterns"