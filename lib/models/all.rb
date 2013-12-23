##
# Configure DB connection
unless ENV['DB_ADAPTER'].blank?
  opts = {
    :adapter => ENV['DB_ADAPTER'],
    :path => ENV['DB_PATH'],
    :host => ENV['DB_HOST'],
    :port => ENV['DB_PORT'],
    :user => ENV['DB_USER'],
    :password => ENV['DB_PASSWORD'],
    :database => ENV['DB_DATABASE']
  }
else
  opts = Application.database
end

##
# There should just be a valid adapter name for this instead.
opts = opts["adapter"] == "sqlite-in-memory" ? "sqlite3::memory:" : opts

DataMapper.setup(:default, opts)
Application.logger.debug "DB Conf: " + opts.to_s

##
# Require all ruby files on or under this level.
Dir[File.join( File.dirname(__FILE__), "**", "*.rb")].each do |f|
  require_relative f
end
