# frozen_string_literal: true

module Hmibo
  # Error class for structured error handling
  class Error
    attr_reader :id, :message, :code, :field

    def initialize(message, code: 422, id: nil, field: nil)
      @message = message
      @code = code
      @id = id
      @field = field
    end

    def to_h
      {
        message: @message,
        code: @code,
        id: @id,
        field: @field
      }.compact
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    def self.from_active_record(record, id: nil)
      errors = []
      
      record.errors.each do |error|
        errors << new(
          error.full_message,
          code: 422,
          id: id,
          field: error.attribute
        )
      end
      
      errors
    end

    def self.validation_error(message, field: nil)
      new(message, code: 422, field: field)
    end

    def self.not_found(message = "Record not found")
      new(message, code: 404)
    end

    def self.unauthorized(message = "Unauthorized")
      new(message, code: 401)
    end

    def self.forbidden(message = "Forbidden")
      new(message, code: 403)
    end

    def self.server_error(message = "Internal server error")
      new(message, code: 500)
    end
  end
end