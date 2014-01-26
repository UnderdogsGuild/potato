##
# Configure DB connection
unless ENV['DB_URI'].nil?
  uri = ENV['DB_URI']
else
  uri = Application.database
end

##
# There should just be a valid adapter name for this instead.
#opts = opts["adapter"] == "sqlite-in-memory" ? "sqlite3::memory:" : opts

Application.db = Sequel.connect(uri)
Application.logger.debug "DB Conf: " + uri

##
# Require all ruby files on or under this level.
Dir[File.join( File.dirname(__FILE__), "**", "*.rb")].each do |f|
	require_relative f
end
