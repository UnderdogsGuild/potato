require 'bundler/setup'
Bundler.require

class Application < Sinatra::Base
  use Rack::Session::Cookie, secret: '2-oWcq(|Yo@ZV)VBdX]<.MEl0JtH.$RVAyX2gyl[Nl{bPRWD/$:./}P', expire_after: (2 * 60 * 60)
  register Sinatra::Namespace
  register Sinatra::ConfigFile
	register Sinatra::Partial

  enable :logging
  set :app_file, __FILE__
  set :root, File.expand_path(File.join(File.dirname(__FILE__), ".."))
  set :views, Proc.new { File.join(root, "templates") }

  set :haml, :format => :html5
	set :db, 0
  config_file "config/application.yaml"

  configure :development, :test do
    set :logger, Logger.new(STDOUT)
    logger.level = Logger::DEBUG
		disable :static
  end

  configure :production do
    set :logfile, "logs/sinatra.log"
    set :logger, Logger.new(logfile 'weekly')
    logger.level = Logger::ERROR

    disable :static
  end

  logger.debug "Execution environment: #{environment}"
end

require_relative 'models/all'
require_relative 'routes/all'
require_relative 'helpers/all'
