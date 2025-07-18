# frozen_string_literal: true

# Example: Converting the existing BulkCreation service to use Hmibo
# 
# Before (original):
# class BulkCreation
#   attr_accessor :errors
#
#   def initialize(bulk_create_params, klass)
#     @params = bulk_create_params
#     @errors = []
#     @klass = klass
#   end
#
#   def call
#     params.each do |param_set|
#       record = @klass.new(param_set.except(:client_side_id))
#
#       unless record.save
#         errors << { id: param_set[:client_side_id], message: record.errors.full_messages.to_sentence,
#                     code: 422 }
#       end
#     end
#   end
#
#   def errors?
#     errors.present?
#   end
# end

# After (using Hmibo):
class BulkCreation < Hmibo::Base
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
    error = Hmibo::Error.new(
      record.errors.full_messages.to_sentence,
      code: 422,
      id: client_side_id
    )
    @service_errors << error
  end
end

# Usage example:
params = [
  { name: "John", email: "john@example.com", client_side_id: "temp-1" },
  { name: "Jane", email: "invalid-email", client_side_id: "temp-2" }
]

result = BulkCreation.call(params, User)

if result.success?
  puts "All users created: #{result.data.map(&:name).join(', ')}"
else
  puts "Errors occurred:"
  result.errors.each do |error|
    puts "- #{error.respond_to?(:id) ? error.id : 'N/A'}: #{error.respond_to?(:message) ? error.message : error}"
  end
end