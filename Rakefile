require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.ruby_opts = '-I. -r spec/spec_helper'
end

task :env do
  ENV['RACK_ENV'] ||= "development"
  require 'bundler/setup'
  Bundler.require
end

task :shell => :env do
  require 'irb'
  require 'models/all'
  ARGV.clear
  IRB.start
end
