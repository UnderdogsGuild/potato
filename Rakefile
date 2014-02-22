require 'rspec/core/rake_task'
require 'bundler/setup'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.ruby_opts = '-I. -r spec/spec_helper'
end

##
# Blatantly copied from:
# https://github.com/sandys/sinatra-haml-warden-bcrypt-jruby-sequel-rakefile-migrations--skeleton/blob/master/Rakefile
namespace :db do
    require 'sequel'
    Sequel.extension :migration
    migration_dir = "migrations"

    task :environment, [:env]do |cmd, args|
			@@env = args[:env] || "development"
			Bundler.require
     require 'models/all'
    end

		task :shell => :environment do
			require 'pry'
			binding.pry
			#ARGV.clear
			#IRB.start
		end

    namespace :migrate do

      desc "Perform automigration (reset your db data)"
      task :auto => :environment do
        ::Sequel.extension :migration
        ::Sequel::Migrator.run Sequel::Model.db, migration_dir, :target => 0
        ::Sequel::Migrator.run Sequel::Model.db, migration_dir
        puts "<= sq:migrate:auto executed"
      end

      desc "Perform migration up/down to VERSION"
      task :to, [:version] => :environment do |t, args|
        version = (args[:version] || ENV['VERSION']).to_s.strip
        ::Sequel.extension :migration
        raise "No VERSION was provided" if version.empty?
        ::Sequel::Migrator.apply(Sequel::Model.db, migration_dir, version.to_i)
        puts "<= sq:migrate:to[#{version}] executed"
      end

      desc "Perform migration up to latest migration available"
      task :up => :environment do
        puts Sequel::Model.db.inspect 
        ::Sequel.extension :migration
        ::Sequel::Migrator.run Sequel::Model.db, migration_dir
        puts "<= sq:migrate:up executed"
      end

      desc "Perform migration down (erase all data)"
      task :down => :environment do
        ::Sequel.extension :migration
        ::Sequel::Migrator.run Sequel::Model.db, migration_dir, :target => 0
        puts "<= sq:migrate:down executed"
      end
    end
end 
