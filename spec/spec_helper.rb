
require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require File.expand_path('../../main', __FILE__)
require 'database_cleaner'

module RSpecMixin
  include Rack::Test::Methods

  def app
    Games::Main
  end
end

RSpec.configure do |config|
  config.include RSpecMixin
  DatabaseCleaner.orm = 'mongoid'
  DatabaseCleaner.strategy = 'truncation'
  DatabaseCleaner[:mongoid].strategy = :truncation
  DatabaseCleaner.clean_with(:truncation)

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
