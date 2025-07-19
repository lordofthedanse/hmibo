# frozen_string_literal: true

# Example: Simple service object patterns using Hmibo
# Inspired by DetectionTek patterns - clean, dependency-free Ruby classes

# Example 1: Basic service pattern
class CreateUser < Hmibo::Base
  def initialize(user_params)
    @user_params = user_params
    super()
  end

  private

  def perform
    return add_error('Name is required') if @user_params[:name].nil?
    return add_error('Email is required') if @user_params[:email].nil?

    user = User.new(@user_params)

    if user.save
      @data = user
    else
      user.errors.full_messages.each { |msg| add_error(msg) }
    end

    self
  end
end

# Example 2: Bulk creation with error tracking
class BulkCreation < Hmibo::Base
  def initialize(params, klass)
    @params = params
    @klass = klass
    super()
  end

  private

  def perform
    return add_error('Params cannot be blank') if @params.nil? || @params.empty?
    return add_error('Class cannot be blank') if @klass.nil?

    created_records = []

    @params.each do |param_set|
      record = @klass.new(param_set.except(:client_side_id))

      if record.save
        created_records << record
      else
        message = record.errors.full_messages.join(', ')
        add_error(message, id: param_set[:client_side_id])
      end
    end

    @data = created_records
    self
  end
end

# Example 3: Simple email validation service (DetectionTek style)
class EmailValidator < Hmibo::Base
  def initialize(emails)
    @emails = emails
    super()
  end

  private

  def perform
    valid_emails = []

    @emails.each do |email|
      if valid_email?(email)
        valid_emails << email
      else
        add_error("#{email} is not a valid email address")
      end
    end

    @data = valid_emails
    self
  end

  def valid_email?(email)
    email.match?(/\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i)
  end
end

# Usage examples:

# Simple service call
user_service = CreateUser.call(name: 'John', email: 'john@example.com')
if user_service.errors?
  puts "Errors: #{user_service.errors}"
else
  puts "Created user: #{user_service.data.name}"
end

# Bulk creation with error handling
params = [
  { name: 'John', email: 'john@example.com', client_side_id: 'temp-1' },
  { name: 'Jane', email: 'invalid-email', client_side_id: 'temp-2' }
]

bulk_service = BulkCreation.call(params, User)
if bulk_service.errors?
  puts 'Some records failed:'
  bulk_service.errors.each do |error|
    puts "- #{error[:id] || 'N/A'}: #{error[:message] || error}"
  end
else
  puts "All users created: #{bulk_service.data.map(&:name).join(', ')}"
end

# Email validation
email_service = EmailValidator.call(['good@email.com', 'bad-email', 'another@good.com'])
puts "Valid emails: #{email_service.data}"
puts "Errors: #{email_service.errors}" if email_service.errors?
