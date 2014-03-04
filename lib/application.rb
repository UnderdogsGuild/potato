require 'bundler/setup'
#Bundler.require
require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/partial'
require 'sinatra/config_file'
require 'rack/contrib'
require 'stringex'
require 'rdiscount'
require 'haml'
require 'sass'

class Application < Sinatra::Base
  use Rack::Session::Cookie, secret: '2-oWcq(|Yo@ZV)VBdX]<.MEl0JtH.$RVAyX2gyl[Nl{bPRWD/$:./}P', expire_after: (2 * 60 * 60)
  register Sinatra::Namespace
  register Sinatra::ConfigFile
	#register Sinatra::Partial

	class NotAllowedError < StandardError;
		def http_status
			403
		end
	end

	configure do
		enable :logging
		set :app_file, __FILE__
		set :root, File.expand_path(File.join(File.dirname(__FILE__), ".."))
		set :views, Proc.new { File.join(root, "templates") }

		set :haml, :format => :html5
		set :db, 0
		config_file "config/application.yaml"
		disable :static
	end

	not_found do
		haml :'pages/errors/404', layout: :errors
	end

	#error NotAllowedError do
		#haml :'pages/error/403', layout: :errors
	#end
end


require_relative 'models/all'
require_relative 'routes/all'
require_relative 'helpers/all'
