# frozen_string_literal: true

require "spec_helper"

class TestService < Hmibo::Base
  attribute :name, :string
  attribute :email, :string

  validates :name, presence: true
  validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\z/ }

  private

  def perform
    success_result("Test completed", { name: name, email: email })
  end
end

RSpec.describe Hmibo::Base do
  let(:test_service_class) { TestService }

  let(:failing_service_class) do
    Class.new(Hmibo::Base) do
      attribute :should_fail, :boolean

      private

      def perform
        raise StandardError, "Test error" if should_fail
        success_result("Success")
      end
    end
  end

  describe "#initialize" do
    it "initializes with empty errors array" do
      service = test_service_class.new
      expect(service.has_errors?).to be(false)
    end

    it "accepts attributes" do
      service = test_service_class.new(name: "John", email: "john@example.com")
      expect(service.name).to eq("John")
      expect(service.email).to eq("john@example.com")
    end
  end

  describe "#call" do
    context "with valid parameters" do
      it "returns success result" do
        service = test_service_class.new(name: "John", email: "john@example.com")
        result = service.call

        expect(result).to be_a(Hmibo::Result)
        expect(result.success?).to be(true)
        expect(result.message).to eq("Test completed")
        expect(result.data).to eq({ name: "John", email: "john@example.com" })
      end
    end

    context "with invalid parameters" do
      it "returns failure result with validation errors" do
        service = test_service_class.new(name: "", email: "invalid-email")
        result = service.call

        expect(result).to be_a(Hmibo::Result)
        expect(result.success?).to be(false)
        expect(result.message).to eq("Invalid parameters")
        expect(result.errors).to include("Name can't be blank")
        expect(result.errors).to include("Email is invalid")
      end
    end

    context "when an error occurs during execution" do
      it "handles the error and returns failure result" do
        service = failing_service_class.new(should_fail: true)
        result = service.call

        expect(result).to be_a(Hmibo::Result)
        expect(result.success?).to be(false)
        expect(result.message).to eq("Test error")
        expect(result.errors).to include("Test error")
      end
    end
  end

  describe ".call" do
    it "provides class-level convenience method" do
      result = test_service_class.call(name: "John", email: "john@example.com")
      
      expect(result).to be_a(Hmibo::Result)
      expect(result.success?).to be(true)
    end
  end

  describe "#has_errors?" do
    it "returns true when errors are present" do
      service = test_service_class.new
      service.send(:add_error, "Test error")
      expect(service.has_errors?).to be(true)
    end

    it "returns false when no errors are present" do
      service = test_service_class.new
      expect(service.has_errors?).to be(false)
    end
  end

  describe "#raise_if_errors" do
    it "raises ServiceError when errors are present" do
      service = test_service_class.new
      service.send(:add_error, "Test error")
      
      expect { service.send(:raise_if_errors) }.to raise_error(Hmibo::ServiceError, "Test error")
    end

    it "does not raise error when no errors are present" do
      service = test_service_class.new
      expect { service.send(:raise_if_errors) }.not_to raise_error
    end
  end
end