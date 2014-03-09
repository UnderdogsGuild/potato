require 'securerandom'

class Application < Sinatra::Base

	##
	# Check for the remember-me token cookie
	# and log the user in after security checks.
	before do
		if token = request.cookies["remember"]
			u = User[remember_token: token]

			if u and u.can?(:log_in)
				session[:user] = u.id

			else
				response.delete_cookie "remember"

			end
		end
	end

	get '/login/?' do
		session[:go_back] ||= request.referrer
		haml :'views/login'
	end
	
	post '/login/?' do
		if params[:action] == "login"
			authenticate!

		elsif params[:action] == "register"
			register!

		else
			haml :'views/login'

		end
	end

	get '/logout/?' do
		require_permission :log_in
		logger.debug "Clearing session for user #{user.id}."

		session.clear
		response.delete_cookie "remember"
		redirect to('/')
	end

	get '/recover/?' do
		# TODO: Implement password recovery
	end
end
