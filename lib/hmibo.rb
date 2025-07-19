# frozen_string_literal: true

require "logger_head"
require_relative "hmibo/version"
require_relative "hmibo/base"
require_relative "hmibo/result"
require_relative "hmibo/error"
require_relative "hmibo/bulk_creation"
require_relative "hmibo/test_helpers"

module Hmibo
  # Exception classes
  class ServiceError < StandardError; end
end
