class DatabaseHelpers

  ##
  # Read configuration values from the parent app to connect to the data store
  def db_connect!
    unless ENV['DB_HOST'].blank?
      opts = {
        :adapter => ENV['DB_ADAPTER'],
        :path => ENV['DB_PATH'],
        :host => ENV['DB_HOST'],
        :port => ENV['DB_PORT'],
        :user => ENV['DB_USER'],
        :password => ENV['DB_PASSWORD'],
        :database => ENV['DB_DB']
      }
    else
      opts = database[environment]
      #conf_file_path = Pathname(root) / "config" / "db.yaml"
      #opts = YAML.load_file(conf_file_path)[environment.to_s]
    end

    # TODO: Wonder if I can set this up in the yml file
    opts = opts['adapter'] == "sqlite-inmemory" ? "sqlite3::memory:" : opts

    DataMapper.setup(:default, opts)
    logger.debug "DM Conf: " + opts.to_s
  end
end

