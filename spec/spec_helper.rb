ENV['RACK_ENV'] ||= "test"

require 'bundler/setup'
require 'application'
require 'rspec'
require 'rack/test'
require 'rr'
require 'capybara/rspec'

Capybara.app = Application

Sequel.extension :migration

RSpec.configure do |c|
	c.include Rack::Test::Methods

	c.expect_with :rspec do |x|
		x.syntax = :expect
	end
	
	c.before(:all) do
		Sequel::Migrator.apply(Application.db, './migrations')

		# After migrating, reset all the models
		NewsEntry.dataset = NewsEntry.dataset
		User.dataset = User.dataset
		Role.dataset = Role.dataset
		Permission.dataset = Permission.dataset
		Page.dataset = Page.dataset
		PageVersion.dataset = PageVersion.dataset
	end

  c.around(:each) do |example|
    Application.db.transaction(:rollback=>:always){example.run}
  end
end
