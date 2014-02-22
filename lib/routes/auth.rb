require 'securerandom'

class Application < Sinatra::Base

	##
	# Check for the remember-me token cookie
	before do
		if token = request.cookies["remember"]
			logger.debug "Found permanent session token in cookie: #{token}"
			user = User[remember_token: token]
			if user and user.can?(:log_in)
				logger.debug "Found associated user #{user.id} from token #{token}. Configuring session."
				session[:user] = user
			else
				logger.debug "Session token #{token} rejected. Clearing cookie."
				response.delete_cookie "remember"
			end
		else
			logger.debug "Permanent session token not found in cookie."
		end
	end

	get '/login' do
		session[:go_back] ||= request.referrer
		haml :'views/login'
	end
	
	post '/login' do
		if params[:action] == "login"
			authenticate!
		elsif params[:action] == "register"
			register!
		else
			haml :'views/login'
		end
	end

	get '/logout' do
		logger.debug "Clearing session for user #{session[:user].id}."
		require_permission :log_in
		session.delete(:user)
		response.delete_cookie "remember"
		redirect to('/')
	end
end
