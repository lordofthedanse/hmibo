# frozen_string_literal: true

require 'bundler/setup'

ENV['RAILS_ENV'] = 'test'

require 'rails'
require 'rails/all'
require 'action_controller'
require 'rspec'

module TestApp
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.cache_classes = true
    config.eager_load = false
    config.consider_all_requests_local = true
    config.active_support.deprecation = :log
    config.log_level = :fatal
    config.secret_key_base = 'test'
    config.hosts.clear

    # In-memory database
    config.active_record.database_url = 'sqlite3::memory:'
  end
end

Rails.application.initialize!

require 'hmibo'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = 'spec/examples.txt'
  config.disable_monkey_patching!
  config.warnings = true

  config.default_formatter = 'doc' if config.files_to_run.one?
  config.profile_examples = 10
  config.order = :random

  # Include Hmibo test helpers
  config.include Hmibo::TestHelpers

  Kernel.srand config.seed
end
