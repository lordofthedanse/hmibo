# frozen_string_literal: true

module Hmibo
  module Concerns
    # Module for geocoding-related functionality
    module Geocoding
      extend ActiveSupport::Concern

      def check_for_coordinates(obj)
        return if obj.geocoded?

        error_message = if defined?(I18n)
          I18n.t("errors.missing_coordinates", class_name: obj.class.name, id: obj.id)
        else
          "Missing coordinates for #{obj.class.name} with id #{obj.id}"
        end
        
        add_error(error_message)
      end

      def raise_if_geocoding_errors
        return if @service_errors.blank?

        error_message = @service_errors.join(", ")
        raise GeocodingError, error_message
      end
    end
  end
end