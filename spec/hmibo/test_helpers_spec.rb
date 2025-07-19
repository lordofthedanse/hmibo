# frozen_string_literal: true

require "rails_helper"

class SuccessService < Hmibo::Base
  def initialize(data = "success")
    @result_data = data
    super()
  end

  private

  def perform
    @data = @result_data
    self
  end
end

class FailureService < Hmibo::Base
  def initialize(error_message = "Something went wrong")
    @error_message = error_message
    super()
  end

  private

  def perform
    add_error(@error_message)
    add_error("Second error", code: 400, id: "test-id")
    self
  end
end

RSpec.describe Hmibo::TestHelpers do
  describe "#expect_service_success" do
    it "passes when service succeeds" do
      service = SuccessService.call("test data")
      result = expect_service_success(service)
      
      expect(result).to eq(service)
      expect(result.data).to eq("test data")
    end

    it "fails when service has errors" do
      service = FailureService.call
      
      expect {
        expect_service_success(service)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected service to succeed/)
    end
  end

  describe "#expect_service_failure" do
    it "passes when service fails" do
      service = FailureService.call
      result = expect_service_failure(service)
      
      expect(result).to eq(service)
    end

    it "checks error count when specified" do
      service = FailureService.call
      expect_service_failure(service, expected_error_count: 2)
    end

    it "fails when service succeeds" do
      service = SuccessService.call
      
      expect {
        expect_service_failure(service)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected service to fail/)
    end

    it "fails when error count doesn't match" do
      service = FailureService.call
      
      expect {
        expect_service_failure(service, expected_error_count: 1)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected 1 errors, but got 2/)
    end
  end

  describe "#expect_service_error" do
    it "passes when service has the expected error message" do
      service = FailureService.call("Custom error")
      expect_service_error(service, "Custom error")
    end

    it "fails when service doesn't have the expected error" do
      service = FailureService.call("Different error")
      
      expect {
        expect_service_error(service, "Expected error")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected error 'Expected error'/)
    end

    it "fails when service succeeds" do
      service = SuccessService.call
      
      expect {
        expect_service_error(service, "Any error")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected service to have errors/)
    end
  end

  describe "#expect_service_error_with_attributes" do
    it "passes when service has error with matching attributes" do
      service = FailureService.call
      expect_service_error_with_attributes(service, code: 400, id: "test-id")
    end

    it "fails when no error matches the attributes" do
      service = FailureService.call
      
      expect {
        expect_service_error_with_attributes(service, code: 500)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /Expected error with attributes/)
    end
  end

  describe "#mock_service" do
    it "creates a mock service with success" do
      mock = mock_service(success: true, data: "test")
      
      expect(mock.errors?).to be(false)
      expect(mock.data).to eq("test")
      expect(mock.errors).to eq([])
    end

    it "creates a mock service with errors" do
      mock = mock_service(success: false, errors: ["error1", "error2"])
      
      expect(mock.errors?).to be(true)
      expect(mock.errors).to eq(["error1", "error2"])
    end
  end

  describe "#stub_service" do
    it "stubs a service class to return specific result" do
      mock = stub_service(SuccessService, success: true, data: "stubbed")
      
      result = SuccessService.call("ignored")
      expect(result).to eq(mock)
      expect(result.data).to eq("stubbed")
    end
  end
end