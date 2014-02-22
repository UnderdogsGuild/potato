require 'securerandom'

class Application < Sinatra::Base

	before do
		if token = request.cookies["remember_me"]
			user = User[remember_token: token]
			if user and user.can? :log_in
				session[:user] = user
			else
				response.delete_cookie "remember_me"
			end
		end
	end

	get '/login' do
		session[:go_back] = request.referrer
		haml :'views/login'
	end
	
	post '/login' do

		@error = nil

		if @user =	User[login: params['login']]
			if @user.can? :log_in
				if @user.login? params['password']
					rand = SecureRandom.hex
					@user.remember_token = rand
					request.set_cookie "remember_me",
						{value: rand, expires: (Time.now + 365*24*60*60)}
					session[:user] = @user
					redirect session[:go_back]
				else
					@error = :password
					haml :'views/login'
				end
			else
				@error = :permission
				haml :'views/login'
			end
		else
			@error = :notfound
			haml :'views/login'
		end
			
	end

	get '/logout' do
		require_permission :log_in
		session[:user] = nil
		#redirect to('/login')
	end
end
