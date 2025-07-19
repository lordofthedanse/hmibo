# frozen_string_literal: true

module Hmibo
  # Service for bulk creation of records with error handling
  # Follows DetectionTek patterns for simple, consistent service objects
  class BulkCreation < Base
    def initialize(params, klass)
      @params = params
      @klass = klass
      super()
    end

    private

    attr_reader :params, :klass

    def perform
      return add_validation_errors if invalid_inputs?

      created_records = []

      @params.each do |param_set|
        record = @klass.new(param_set.except(:client_side_id))

        if record.save
          created_records << record
        else
          add_error_for_record(record, param_set[:client_side_id])
        end
      end

      @data = created_records
      self
    end

    def invalid_inputs?
      return true if @params.nil? || (defined?(@params.blank?) && @params.blank?) || (@params.respond_to?(:empty?) && @params.empty?)
      return true if @klass.nil?

      false
    end

    def add_validation_errors
      add_error('Params cannot be blank') if @params.nil? || (defined?(@params.blank?) && @params.blank?) || (@params.respond_to?(:empty?) && @params.empty?)
      add_error('Class cannot be blank') if @klass.nil?
    end

    def add_error_for_record(record, client_side_id)
      if record.errors.respond_to?(:full_messages)
        record.errors.full_messages.each do |message|
          add_error(message, code: 422, id: client_side_id)
        end
      else
        add_error('Record validation failed', code: 422, id: client_side_id)
      end
    end
  end
end
