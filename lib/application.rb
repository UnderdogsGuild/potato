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
	disable :static

  #configure :development do
    #set :logger, Logger.new(STDOUT)
    #logger.level = Logger::DEBUG
  #end

	#configure :test do
		#set :logger, Logger.new(STDOUT)
		#logger.level = Logger::ERROR
	#end

  #configure :production do
    #set :logfile, "logs/sinatra.log"
    #set :logger, Logger.new(logfile 'weekly')
    #logger.level = Logger::INFO
  #end
end

require_relative 'models/all'
require_relative 'routes/all'
require_relative 'helpers/all'
