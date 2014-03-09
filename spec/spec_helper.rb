ENV['RACK_ENV'] ||= "test"

require 'bundler/setup'
require 'rspec'
require 'rack/test'
require 'rr'
require 'capybara/rspec'
require 'capybara/poltergeist'
require 'active_support/core_ext/class/subclasses'
require 'factory_girl'
require 'faker'

require 'application'

module SpecHelpers
	def app
		Application
	end
end

RSpec.configure do |c|
	c.include Rack::Test::Methods
	c.include FactoryGirl::Syntax::Methods
	c.include SpecHelpers

	c.expect_with :rspec do |x|
		x.syntax = :expect
	end

	c.before :suite do
		Capybara.app = Application
		Capybara.register_driver :poltergeist do |app|
			Capybara::Poltergeist::Driver.new(app, { phantomjs_logger: nil })
		end
		Capybara.javascript_driver = :poltergeist

		Sequel.extension :migration

		# Get our brand new in-memory DB up
		Sequel::Migrator.run(Application.db, './lib/models/migrations', target: 0)
		Sequel::Migrator.run(Application.db, './lib/models/migrations')

		# After migrating, reset all the models
		Sequel::Model.subclasses.each do |model|
			model.dataset = model.dataset
		end

		# Load and lint all fixture factories
		FactoryGirl.find_definitions

		FactoryGirl.define do
			to_create { |instance| instance.save }
		end

		Application.db.transaction(rollback: :always) do
			FactoryGirl.lint
		end
	end

	# c.before :each  do
	# 	DatabaseCleaner.start
	# end

	# c.after :each do
	# 	DatabaseCleaner.clean
	# end

  c.around(:each) do |example|
    Application.db.transaction(:rollback=>:always){example.run}
  end

	c.after :suite do
		Sequel::Migrator.run(Application.db, './lib/models/migrations', target: 0)
	end
end
