require 'rspec/core/rake_task'
require 'bundler/setup'
require 'turnout/rake_tasks'

desc "Run all specs"
RSpec::Core::RakeTask.new(:spec) do |spec|
	spec.ruby_opts = '-Ilib:spec -r spec_helper'
  spec.rspec_opts = '--order random --format progress --color'
end

# task :spec => :minify
task :default => :spec

directory "public/css"

# Order is important!
jsfiles = [
  'lib/js/libs/jquery-2.1.1.js',
  'lib/js/app.js'
]

sassfiles = FileList["lib/sass/**/*.scss"]

desc "Minify Javascript files"
file 'public/js/app.min.js' => jsfiles do |t|
  `uglifyjs #{t.prerequisites.join(" ")} -o #{t.name}`
end

desc "Minify CSS files"
file 'public/css/app.min.css' => sassfiles do |t|
  `sass -t compressed lib/sass/app.scss #{t.name}`
end

file 'public/css/app.min.css' => 'public/css'

desc "Minify Javascript and CSS files"
multitask :minify => ['public/js/app.min.js', 'public/css/app.min.css']

task :minclean do
  `rm public/js/app.js public/css/app.css`
end

##
# Blatantly copied from:
# https://github.com/sandys/sinatra-haml-warden-bcrypt-jruby-sequel-rakefile-migrations--skeleton/blob/master/Rakefile
namespace :db do
	require 'sequel'
	Sequel.extension :migration
	migration_dir = "lib/models/migrations"

	task :environment, [:env] do |cmd, args|
		@@env = args[:env] || "development"
		Bundler.require
		require 'models/all'
	end

	task :shell => :environment do
		require 'pry'
		binding.pry
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
		u = create(:user, login: "user", password: @password, email: "me@mkaito.com")
		u.add_role create(:role, label: "admin", root: true)
		create_list(:forum_thread, 20)
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
