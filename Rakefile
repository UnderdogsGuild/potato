require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.ruby_opts = '-I. -r spec/spec_helper'
end

task :env do
  ENV['RACK_ENV'] ||= "development"
  require 'bundler/setup'
  Bundler.require
  Mongoid.load! File.expand_path( File.join( File.dirname(__FILE__), "config", "mongoid.yml" ) )
end

namespace :db do
  task :migrate => :env do
    puts "Clearing..."
    require 'database_cleaner'
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  task :seed => :migrate do
    puts "Seeding..."
    @news_entry = NewsEntry.create title: "Test entries are cool", tagline: "They really are",
      content: "Oh so fucking cool", published: true
    @page = Page.create title: "Pagey pagey on the wall", content: "Who's the prettiest coder of all"
    puts "Done."
  end
end

task :shell => :env do
  require 'irb'
  require 'models/all'
  ARGV.clear
  IRB.start
end
