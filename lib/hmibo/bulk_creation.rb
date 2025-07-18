# frozen_string_literal: true

module Hmibo
  # Service for bulk creation of records with error handling
  class BulkCreation < Base
    def initialize(params, klass)
      @params = params
      @klass = klass
      super()
    end

    def validate_inputs
      add_error("Params cannot be blank") if @params.blank?
      add_error("Class cannot be blank") if @klass.blank?
      !has_errors?
    end

    private

    attr_reader :params, :klass

    def perform
      created_records = []
      
      @params.each do |param_set|
        record = @klass.new(param_set.except(:client_side_id))
        
        if record.save
          created_records << record
        else
          add_error_for_record(record, param_set[:client_side_id])
        end
      end
      
      if has_errors?
        failure_result("Some records failed to create", @service_errors)
      else
        success_result("All records created successfully", created_records)
      end
    end

    def add_error_for_record(record, client_side_id)
      error = Error.new(
        record.errors.full_messages.to_sentence,
        code: 422,
        id: client_side_id
      )
      @service_errors << error
    end
  end
end