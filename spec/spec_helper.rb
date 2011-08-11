ENV['RACK_ENV'] ||= "test"

require 'bundler/setup'
Bundler.require(:default, :test)

#require 'application'

module SpecHelpers
  def app
    Application
  end
end

Webrat.configure do |c|
  c.mode = :rack
end

RSpec.configure do |c|
  c.include Rack::Test::Methods
  c.include Webrat::Methods
  c.include Webrat::Matchers
  c.include SpecHelpers

  c.mock_with :rr

  c.before :all do
    DataMapper.auto_migrate!
  end

  c.after :all do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end
