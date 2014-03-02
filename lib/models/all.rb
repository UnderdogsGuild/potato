require 'sequel'

if Application.environment == :development || Application.environment == :test
	require 'sqlite3'
else
	require 'mysql2'
end

##
# Configure DB connection
unless ENV['DB_URI'].nil?
  uri = ENV['DB_URI']
else
  uri = Application.database
end

Application.db = Sequel.connect(uri)

##
# Require all ruby files on or under this level.
Dir[File.join( File.dirname(__FILE__), "**", "*.rb")].each do |f|
	require_relative f unless f.include? "/migrations/"
end
