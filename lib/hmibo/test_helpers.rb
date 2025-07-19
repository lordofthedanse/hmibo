# frozen_string_literal: true

module Hmibo
  # Test helpers for RSpec testing of Hmibo services
  module TestHelpers
    # Assert that a service executed successfully
    def expect_service_success(service)
      expect(service.errors?).to be(false), 
        "Expected service to succeed, but got errors: #{service.errors}"
      service
    end

    # Assert that a service failed with errors
    def expect_service_failure(service, expected_error_count: nil)
      expect(service.errors?).to be(true), 
        "Expected service to fail, but it succeeded with data: #{service.data}"
      
      if expected_error_count
        expect(service.errors.length).to eq(expected_error_count),
          "Expected #{expected_error_count} errors, but got #{service.errors.length}: #{service.errors}"
      end
      
      service
    end

    # Assert that a service has a specific error message
    def expect_service_error(service, message)
      expect(service.errors?).to be(true), 
        "Expected service to have errors, but it succeeded"
      
      error_messages = service.errors.map do |error|
        error.is_a?(Hash) ? error[:message] : error.to_s
      end
      
      expect(error_messages).to include(message),
        "Expected error '#{message}' but got: #{error_messages}"
      
      service
    end

    # Assert that a service has errors with specific attributes
    def expect_service_error_with_attributes(service, attributes = {})
      expect(service.errors?).to be(true), 
        "Expected service to have errors, but it succeeded"
      
      matching_error = service.errors.find do |error|
        next false unless error.is_a?(Hash)
        
        attributes.all? { |key, value| error[key] == value }
      end
      
      expect(matching_error).to be_present,
        "Expected error with attributes #{attributes} but got: #{service.errors}"
      
      service
    end

    # Create a mock service for testing
    def mock_service(success: true, data: nil, errors: [])
      service = instance_double("MockService")
      allow(service).to receive(:errors?).and_return(!errors.empty?)
      allow(service).to receive(:data).and_return(data)
      allow(service).to receive(:errors).and_return(errors)
      service
    end

    # Stub a service class to return a specific result
    def stub_service(service_class, success: true, data: nil, errors: [])
      mock = mock_service(success: success, data: data, errors: errors)
      allow(service_class).to receive(:call).and_return(mock)
      mock
    end
  end
end