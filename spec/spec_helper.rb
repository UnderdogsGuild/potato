ENV['RACK_ENV'] ||= "test"

require 'bundler/setup'
require 'application'
require 'rspec'
require 'rack/test'
require 'rr'
require 'capybara/rspec'
require 'active_support/core_ext/class/subclasses'
require 'factory_girl'
require 'faker'


Capybara.app = Application

Sequel.extension :migration

RSpec.configure do |c|
	c.include Rack::Test::Methods
	c.include FactoryGirl::Syntax::Methods

	c.expect_with :rspec do |x|
		x.syntax = :expect
	end
	
	c.before(:suite) do
		# Get our brand new in-memory DB up
		Sequel::Migrator.apply(Application.db, './lib/models/migrations')

		# After migrating, reset all the models
		Sequel::Model.subclasses.each do |model|
			model.dataset = model.dataset
		end
		#NewsEntry.dataset = NewsEntry.dataset
		#User.dataset = User.dataset
		#Role.dataset = Role.dataset
		#Permission.dataset = Permission.dataset
		#Page.dataset = Page.dataset
		#PageVersion.dataset = PageVersion.dataset
		#ForumThread.dataset = ForumThread.dataset
		#ForumPost.dataset= ForumPost.dataset

		# Load and lint all fixture factories
		FactoryGirl.find_definitions
		FactoryGirl.reload

		FactoryGirl.define do
			to_create { |instance| instance.save }
		end

		Application.db.transaction(rollback: :always) do
			FactoryGirl.lint
		end
	end

  c.around(:each) do |example|
    Application.db.transaction(:rollback=>:always){example.run}
  end
end
