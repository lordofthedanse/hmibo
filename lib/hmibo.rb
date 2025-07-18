# frozen_string_literal: true

require "active_model"
require "active_support"
require "active_support/core_ext"

require_relative "hmibo/version"
require_relative "hmibo/base"
require_relative "hmibo/result"
require_relative "hmibo/error"
require_relative "hmibo/bulk_creation"
require_relative "hmibo/concerns/geocoding"
require_relative "hmibo/concerns/notifiable"

module Hmibo
  # Exception classes
  class ServiceError < StandardError; end
  class ValidationError < ServiceError; end
  class GeocodingError < ServiceError; end
end