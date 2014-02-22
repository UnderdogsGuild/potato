class Application < Sinatra::Base
	helpers do
		def require_permission(perm)
			if session[:user].nil?
				logger.debug "No user found at restricted route	check point. Saving path, redirecting to auth challenge."
				session[:go_back] = request.path_info
				redirect to('/login')
			end

			unless session[:user].can?(perm)
				logger.warning "User #{session[:user].id} attempted to access restricted path #{request.path_info}, but does not have the required permission token."
				halt 403
			end
		end

		def can?(perm)
			session[:user].can?(perm)
		end

		def authenticate!
			if user =	User[login: params['username']]
				if user.can?(:log_in)
					if user.login? params['password']

						if params['remember']
							logger.debug "Setting up permanent session for user #{user.login}"
							rand = SecureRandom.hex(32)
							user.update remember_token: rand
							response.set_cookie "remember",
								{value: rand, expires: (Time.now + 365*24*60*60)}
						end

						logger.debug "User #{user.login} authenticated. Configuring session."
						session[:user] = user

						if session.has_key?(:go_back)
							redirect session.delete(:go_back)
						else
							redirect '/'
						end

					else
						logger.debug "User #{user.login} provided wrong password."
						@error = :password
						haml :'views/login'
					end

				else
					logger.debug "User #{user.login} is not allowed to log in."
					@error = :permission
					haml :'views/login'
				end

			else
				logger.debug "Requested user not found in database."
				@error = :notfound
				haml :'views/login'
			end
		end

		def register!
		end
	end
end
