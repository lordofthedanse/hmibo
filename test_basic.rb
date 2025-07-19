#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('lib', __dir__))

require 'hmibo'

# Test basic service
class TestService < Hmibo::Base
  def initialize(name: nil)
    @name = name
    super()
  end

  private

  def perform
    return add_error('Name is required') if @name.nil? || @name.empty?

    @data = { name: @name }
    self
  end
end

puts 'Testing Hmibo gem...'

# Test successful service
service = TestService.call(name: 'John')
puts "Success test: #{!service.errors?} (#{service.data})"

# Test error case
service = TestService.call(name: '')
puts "Error test: #{service.errors?} (#{service.errors.first})"

# Test BulkCreation
class MockRecord
  attr_reader :errors

  def initialize(params)
    @params = params
    @errors = []
  end

  def save
    if @params[:name] && !@params[:name].empty?
      true
    else
      @errors << "Name can't be blank"
      false
    end
  end

  class << self
    def full_messages
      self
    end

    def join(_separator)
      "Name can't be blank"
    end
  end
end

bulk = Hmibo::BulkCreation.call([{ name: 'John' }, { name: '' }], MockRecord)
puts "Bulk creation test: #{bulk.errors?} (#{bulk.errors.length} errors)"

puts 'All tests completed!'
