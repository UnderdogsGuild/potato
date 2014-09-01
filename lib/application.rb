require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/namespace'
require 'sinatra/config_file'
require 'encrypted_cookie'
require 'rack/contrib'
require 'stringex'
require 'rdiscount'
require 'rack/turnout'
require 'haml'
require 'sass'
require 'i18n'

class Application < Sinatra::Base

	configure do
		register Sinatra::Namespace
		register Sinatra::ConfigFile
		::I18n.enforce_available_locales = true

		enable :logging
		set :app_file, __FILE__
		set :root, File.expand_path(File.join(File.dirname(__FILE__), ".."))
		set :views, Proc.new { File.join(root, "templates") }

		set :haml, :format => :html5
		set :db, 0
		disable :static
		config_file "config/application.yaml"
	end

	configure :production do
		use Rack::Session::EncryptedCookie,
			secret: '9a0aff2e4861436d5777c8d0a801994603a5faa4fd77f99ae4d0bc10b73ce5fa',
			expire_after: (2 * 60 * 60)
	end

	configure :productiion, :development do
		use Rack::Turnout
	end

	configure :test, :development do
		use Rack::Session::Cookie,
			secret: '9a0aff2e4861436d5777c8d0a801994603a5faa4fd77f99ae4d0bc10b73ce5fa',
			expire_after: (2 * 60 * 60)
	end

	configure :test do
		disable :logging
		enable :static
		set :public_folder, Proc.new { File.join(root, "public") }
	end

	class NotAllowedError < StandardError
		def http_status
			403
		end
	end

	##
	# Error pages
	not_found do; haml :'pages/errors/404', layout: :errors; end
	error NotAllowedError do; haml :'pages/errors/403', layout: :errors; end

	##
	# All requests except GET requests will require a valid csrf
	before do
		unless request.request_method == "GET"
			require_valid_csrf_token
		end
	end
end


require_relative 'models/all'
require_relative 'routes/all'
require_relative 'helpers/all'
