# frozen_string_literal: true

require 'rails_helper'

# Mock ActiveRecord model for testing
class User
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations

  attribute :name, :string
  attribute :email, :string

  validates :name, presence: true
  validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\z/ }

  def save
    return false unless valid?

    @persisted = true
    true
  end

  def persisted?
    @persisted || false
  end

  def id
    @id ||= rand(1000)
  end
end

class CreateUserService < Hmibo::Base
  def initialize(user_params)
    @user_params = user_params
    super()
  end

  private

  def perform
    user = User.new(@user_params)

    if user.save
      @data = user
    else
      user.errors.full_messages.each { |msg| add_error(msg) }
    end

    self
  end
end

RSpec.describe 'Rails Integration' do
  describe 'service objects work in Rails environment' do
    it 'can create users successfully' do
      service = CreateUserService.call(name: 'John', email: 'john@example.com')

      expect(service.errors?).to be(false)
      expect(service.data).to be_a(User)
      expect(service.data.name).to eq('John')
      expect(service.data.email).to eq('john@example.com')
    end

    it 'handles validation errors' do
      service = CreateUserService.call(name: '', email: 'invalid')

      expect(service.errors?).to be(true)
      expect(service.errors.length).to eq(2)
      expect(service.errors).to include(hash_including(message: "Name can't be blank"))
      expect(service.errors).to include(hash_including(message: 'Email is invalid'))
    end

    it 'logs errors when Rails is available' do
      allow(Rails.logger).to receive(:error)

      service = CreateUserService.new(name: 'John', email: 'john@example.com')
      service.send(:log_error, StandardError.new('Test error'))

      expect(Rails.logger).to have_received(:error).with('There was an error in CreateUserService: Test error')
    end
  end

  describe 'BulkCreation with Rails models' do
    it 'creates multiple users' do
      params = [
        { name: 'John', email: 'john@example.com' },
        { name: 'Jane', email: 'jane@example.com' }
      ]

      service = Hmibo::BulkCreation.call(params, User)

      expect(service.errors?).to be(false)
      expect(service.data.length).to eq(2)
      expect(service.data.all? { |u| u.is_a?(User) }).to be(true)
    end

    it 'handles mixed success and failure' do
      params = [
        { name: 'John', email: 'john@example.com' },
        { name: '', email: 'invalid', client_side_id: 'temp-123' }
      ]

      service = Hmibo::BulkCreation.call(params, User)

      expect(service.errors?).to be(true)
      expect(service.data.length).to eq(1) # One successful creation
      expect(service.errors.length).to eq(2) # Two validation errors

      error_with_id = service.errors.find { |e| e[:id] == 'temp-123' }
      expect(error_with_id).to be_present
    end
  end
end
