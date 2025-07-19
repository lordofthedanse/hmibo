# frozen_string_literal: true

module Hmibo
  # Base service class that provides common patterns for service objects
  # Inspired by DetectionTek patterns - simple, dependency-free Ruby classes
  class Base
    attr_accessor :errors, :data

    def initialize(*args)
      @errors = []
      @data = nil
      setup(*args) if respond_to?(:setup, true)
    end

    # Main entry point for service execution
    def call
      perform
    rescue StandardError => e
      handle_error(e)
      self
    end

    # Class method for convenient service execution
    def self.call(*args, **kwargs)
      new(*args, **kwargs).call
    end

    def errors?
      !@errors.empty?
    end

    private

    # Override this method in subclasses to implement business logic
    def perform
      raise NotImplementedError, 'Subclasses must implement #perform'
    end

    # Handle errors that occur during execution
    def handle_error(error)
      log_error(error, context: "#{self.class.name} execution")
      @errors << error.message
    end

    # Add an error to the errors collection
    def add_error(message, code: 422, id: nil)
      error = if message.is_a?(Hash)
                message
              else
                { message: message, code: code, id: id }
              end
      @errors << error
      self
    end

    # Log error using LoggerHead for structured logging with context
    def log_error(error, context: nil)
      provided_context = context || "in #{self.class.name}"
      LoggerHead.new(error, provided_context: provided_context).call
    end
  end
end
