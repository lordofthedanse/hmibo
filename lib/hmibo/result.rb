# frozen_string_literal: true

module Hmibo
  # Result object for service operations
  class Result
    attr_reader :success, :message, :data, :errors

    def initialize(success, message, data = nil, errors = [])
      @success = success
      @message = message
      @data = data
      @errors = Array(errors)
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    def error?
      failure?
    end

    def errors?
      @errors.present?
    end

    def to_h
      {
        success: @success,
        message: @message,
        data: @data,
        errors: @errors
      }
    end

    def to_json(*args)
      to_h.to_json(*args)
    end

    # Factory methods for creating results
    def self.success(message = 'Success', data = nil)
      new(true, message, data, [])
    end

    def self.failure(message, errors = [])
      new(false, message, nil, Array(errors))
    end

    def self.error(message, errors = [])
      failure(message, errors)
    end
  end
end
