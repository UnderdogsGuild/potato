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
require 'timecop'

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
	c.mock_with :rr

	c.expect_with :rspec do |x|
		x.syntax = :expect
	end
	
	migdir = File.expand_path(File.join(Application.root, 'lib', 'models', 'migrations'))

	c.before :suite do
		Capybara.app = Application
		Capybara.register_driver :poltergeist do |app|
			Capybara::Poltergeist::Driver.new(app, { phantomjs_logger: nil })
		end
		Capybara.javascript_driver = :poltergeist

		Sequel.extension :migration

		# Get our DB up to speed
		Sequel::Migrator.run(Application.db, migdir, target: 0)
		Sequel::Migrator.run(Application.db, migdir)

		# After migrating, reset all the models
		Sequel::Model.subclasses.each do |model|
			model.dataset = model.dataset
		end

		# Load and lint all fixture factories
		FactoryGirl.find_definitions

		FactoryGirl.define do
			to_create { |instance| instance.save }
		end

		# Application.db.transaction(rollback: :always) do
		# 	FactoryGirl.lint
		# end
	end

  c.around(:each) do |example|
    Application.db.transaction(:rollback=>:always){example.run}
  end

	# c.after :suite do
	# 	Sequel::Migrator.run(Application.db, migdir, target: 0)
	# end
end
