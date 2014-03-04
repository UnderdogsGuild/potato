require 'active_support/core_ext/numeric/time'

class Application < Sinatra::Base
	helpers do
		def user
			session.has_key?(:user) ? User[id: session[:user]] : nil
		end

		def authorize(perm)
			user ? user.can?(perm) : false
		end

		def require_permission(perm)
			unless user
				#logger.debug "No user found at restricted route	check point. Saving path, redirecting to auth challenge."
				session[:go_back] = request.path_info
				redirect to('/login')
			end

			unless authorize(perm)
				#logger.warning "User #{session[:user].id} attempted to access restricted path #{request.path_info}, but does not have the required permission token."
				raise NotAllowedError, "User lacks required permission token."
			end
		end

		def authenticate!
			if u = User[login: params['username']]
				if u.can?(:log_in)
					if u.login? params['password']

						if params['remember']
							#logger.debug "Setting up permanent session for user #{user.login}"
							rand = SecureRandom.hex(32)
							u.update remember_token: rand
							response.set_cookie "remember",
								{value: rand, expires: (Time.now + 365*24*60*60)}
						end

						#logger.debug "User #{user.login} authenticated. Configuring session."
						session[:user] = u.id

						redirect session.has_key?(:go_back) ? session.delete(:go_back) : '/'

					else
						#logger.debug "User #{user.login} provided wrong password."
						@error = :password
						haml :'views/login'
					end

				else
					#logger.debug "User #{user.login} is not allowed to log in."
					@error = :permission
					haml :'views/login'
				end

			else
				#logger.debug "Requested user not found in database."
				@error = :notfound
				haml :'views/login'
			end
		end

		def register!
		end
	end
end
