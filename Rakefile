require 'rspec/core/rake_task'
require 'bundler/setup'
require 'turnout/rake_tasks'

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |spec|
	spec.ruby_opts = '-Ilib:spec -r spec_helper'
  spec.rspec_opts = '--order random --format documentation --color'
end

# Make sure js and css are in place for phantomjs dependant specs.
task :spec => :minify

# Run everything as default task
task :default => :spec

##
# Order is important!
# Put libraries in the libs folder.
# Put plugins that depend on libraries in the plugin folder.
# Put any application code that uses libs and plugins in top-level .js files.
#
# libs and plugins can contain additional folders for convenience, but don't
# rely on their ordering.
jsfiles = FileList['lib/js/libs/**/*.js', 'lib/js/plugins/**/*.js', 'lib/js/*.js']

# These are just used for timestamp checking.
sassfiles = FileList["lib/sass/**/*.scss"]

desc "Minify Javascript files"
file 'public/js/app.min.js' => jsfiles do |t|
  `uglifyjs #{t.prerequisites.join(" ")} -o #{t.name}`
end

desc "Minify CSS files"
file 'public/css/app.min.css' => sassfiles do |t|
  `sass -t compressed lib/sass/app.scss #{t.name}`
end

# Create the output folder if necessary
directory 'public/css'
file 'public/css/app.min.css' => 'public/css'

# Asset minification will run in parallel when appropriate
desc "Minify Javascript and CSS files"
multitask :minify => ['public/js/app.min.js', 'public/css/app.min.css']

##
# Blatantly copied from:
# https://github.com/sandys/sinatra-haml-warden-bcrypt-jruby-sequel-rakefile-migrations--skeleton/blob/master/Rakefile
namespace :db do
	require 'sequel'
	Sequel.extension :migration
	migration_dir = "lib/models/migrations"

	task :reset do
		`mysql -uroot -p -e 'drop database if exists underdogs; create database underdogs; drop database if exists underdogs_test; create database underdogs_test;'`
	end

	task :environment, [:env] do |cmd, args|
		# @@env = args[:env] || "development"
		Bundler.require
		require 'models/all'
	end

	task :shell => :environment do
		require 'pry'
		pry
	end

	desc "Seed the database"
	task :seed => "migrate:auto" do
		require 'faker'
		require 'factory_girl'
		require 'active_support/core_ext/class/subclasses'

		# After migrating, reset all the models
		Sequel::Model.subclasses.each do |model|
			model.dataset = model.dataset
		end

		include FactoryGirl::Syntax::Methods
		FactoryGirl.find_definitions

		FactoryGirl.define do
			to_create { |instance| instance.save }
		end

		@password = Digest::SHA2.new(512).update("password").to_s
		u = create(:user, login: "user", password: @password, email: "myfancymail@example.com")
		u.add_role create(:role, label: "admin", root: true)
		create_list(:tag, 5)
		create_list(:forum_thread, 20)
		ForumThread.each do |t|
			t.add_tag_by_name Tag.all.sample.name
		end
	end

	namespace :migrate do

		desc "Perform automigration (reset your db data)"
		task :auto => :environment do
			::Sequel::Migrator.run Sequel::Model.db, migration_dir, :target => 0
			::Sequel::Migrator.run Sequel::Model.db, migration_dir
			puts "<= sq:migrate:auto executed"
		end

		desc "Perform migration up/down to VERSION"
		task :to, [:version] => :environment do |t, args|
			version = (args[:version] || ENV['VERSION']).to_s.strip
			raise "No VERSION was provided" if version.empty?
			::Sequel::Migrator.apply(Sequel::Model.db, migration_dir, version.to_i)
			puts "<= sq:migrate:to[#{version}] executed"
		end

		desc "Perform migration up to latest migration available"
		task :up => :environment do
			puts Sequel::Model.db.inspect 
			::Sequel::Migrator.run Sequel::Model.db, migration_dir
			puts "<= sq:migrate:up executed"
		end

		desc "Perform migration down (erase all data)"
		task :down => :environment do
			::Sequel::Migrator.run Sequel::Model.db, migration_dir, :target => 0
			puts "<= sq:migrate:down executed"
		end
	end
end 
