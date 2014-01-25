ENV['RACK_ENV'] ||= "test"

require 'bundler/setup'
require 'application'
require 'rspec'
require 'rack/test'
require 'rr'
require 'webrat'

module SpecHelpers
  def app
    Application
  end
end

Webrat.configure do |c|
	c.mode = :rack
end

Sequel.extension :migration

RSpec.configure do |c|
	c.include Rack::Test::Methods
  c.include Webrat::Methods
  c.include Webrat::Matchers
  c.include SpecHelpers
	
	c.before(:all) do
		Sequel::Migrator.apply(Application.db, './migrations')
	end

  c.around(:each) do |example|
    Application.db.transaction(:rollback=>:always){example.run}
  end
end
