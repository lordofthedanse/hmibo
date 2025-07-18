# frozen_string_literal: true

module Hmibo
  # Base service class that provides common patterns for service objects
  class Base
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    attr_reader :result

    def initialize(attributes = {})
      @service_errors = []
      @result = nil
      super(attributes)
    end

    # Main entry point for service execution
    def call
      validate_inputs
      return failure_result("Invalid parameters", validation_error_messages) unless valid?

      perform
    rescue StandardError => e
      handle_error(e)
    end

    # Class method for convenient service execution
    def self.call(*args)
      new(*args).call
    end

    private

    # Override this method in subclasses to implement business logic
    def perform
      raise NotImplementedError, "Subclasses must implement #perform"
    end

    # Validate inputs before execution
    def validate_inputs
      # Override in subclasses for custom validation
      valid?
    end

    # Handle errors that occur during execution
    def handle_error(error)
      Rails.logger.error("#{self.class.name} error: #{error.message}") if defined?(Rails)
      @service_errors << error.message
      failure_result(error.message, [error.message])
    end

    # Create a success result
    def success_result(message = "Success", data = nil)
      @result = Result.success(message, data)
    end

    # Create a failure result
    def failure_result(message, errors = [])
      @service_errors.concat(Array(errors))
      @result = Result.failure(message, @service_errors)
    end

    # Check if the service has any errors
    def has_errors?
      @service_errors.present?
    end
    public :has_errors?

    # Get validation errors as an array
    def validation_error_messages
      return [] unless errors.respond_to?(:full_messages)
      
      errors.full_messages
    end

    # ActiveModel errors accessor
    def errors_accessor
      @errors_accessor ||= ActiveModel::Errors.new(self)
    end

    # Add an error to the errors collection
    def add_error(message)
      @service_errors << message
    end

    # Clear all errors
    def clear_errors
      @service_errors.clear
    end

    # Raise an error if there are any errors in the collection
    def raise_if_errors
      return if @service_errors.blank?

      error_message = @service_errors.join(", ")
      raise ServiceError, error_message
    end
  end
end