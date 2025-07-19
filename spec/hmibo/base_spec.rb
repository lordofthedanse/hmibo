# frozen_string_literal: true

require "spec_helper"

class TestService < Hmibo::Base
  def initialize(name: nil, email: nil)
    @name = name
    @email = email
    super()
  end

  private

  attr_reader :name, :email

  def perform
    add_error("Name is required") if @name.nil? || @name.empty?
    add_error("Email is required") if @email.nil? || @email.empty?
    add_error("Email is invalid") if !@email.nil? && !@email.empty? && !valid_email?(@email)
    
    return self if errors?
    
    @data = { name: @name, email: @email }
    self
  end

  def valid_email?(email)
    email.match?(/\A[^@\s]+@[^@\s]+\z/)
  end
end

class FailingService < Hmibo::Base
  def initialize(should_fail: false)
    @should_fail = should_fail
    super()
  end

  private

  def perform
    raise StandardError, "Test error" if @should_fail
    
    @data = "Success"
    self
  end
end

RSpec.describe Hmibo::Base do
  describe "#initialize" do
    it "initializes with empty errors array" do
      service = TestService.new
      expect(service.errors?).to be(false)
      expect(service.errors).to eq([])
    end

    it "initializes with nil data" do
      service = TestService.new
      expect(service.data).to be_nil
    end
  end

  describe "#call" do
    context "with valid parameters" do
      it "returns self with data" do
        service = TestService.new(name: "John", email: "john@example.com")
        result = service.call

        expect(result).to eq(service)
        expect_service_success(result)
        expect(result.data).to eq({ name: "John", email: "john@example.com" })
      end
    end

    context "with invalid parameters" do
      it "returns self with errors" do
        service = TestService.new(name: "", email: "invalid-email")
        result = service.call

        expect(result).to eq(service)
        expect_service_failure(result, expected_error_count: 2)
        expect_service_error(result, "Name is required")
        expect_service_error(result, "Email is invalid")
      end
    end

    context "when an error occurs during execution" do
      it "handles the error and returns self with error message" do
        service = FailingService.new(should_fail: true)
        result = service.call

        expect(result).to eq(service)
        expect_service_failure(result)
        expect(result.errors).to include("Test error")
      end
    end
  end

  describe ".call" do
    it "provides class-level convenience method" do
      result = TestService.call(name: "John", email: "john@example.com")
      
      expect(result).to be_a(TestService)
      expect_service_success(result)
    end
  end

  describe "#errors?" do
    it "returns true when errors are present" do
      service = TestService.new
      service.send(:add_error, "Test error")
      expect(service.errors?).to be(true)
    end

    it "returns false when no errors are present" do
      service = TestService.new
      expect(service.errors?).to be(false)
    end
  end

  describe "#add_error" do
    it "adds structured error with defaults" do
      service = TestService.new
      service.send(:add_error, "Test error")
      
      expect(service.errors).to include({
        message: "Test error",
        code: 422,
        id: nil
      })
    end

    it "adds structured error with custom code and id" do
      service = TestService.new
      service.send(:add_error, "Custom error", code: 400, id: "abc123")
      
      expect(service.errors).to include({
        message: "Custom error", 
        code: 400,
        id: "abc123"
      })
    end

    it "accepts hash errors directly" do
      service = TestService.new
      error_hash = { message: "Direct hash", code: 500 }
      service.send(:add_error, error_hash)
      
      expect(service.errors).to include(error_hash)
    end
  end
end