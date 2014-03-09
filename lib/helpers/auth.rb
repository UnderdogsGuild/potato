require 'active_support/core_ext/numeric/time'

class Application < Sinatra::Base
	helpers do
		##
		# Convenience method to check for and retrieve a user object
		def user
			session.has_key?(:user) ? User[id: session[:user]] : nil
		end

		##
		# Convenience method to check the current user for a certain perm token.
		def authorize(perm)
			user ? user.can?(perm) : false
		end

		##
		# Route helper. Makes sure there is an active user that has the required
		# perm token. Save the current URL, so we can send them back after they log
		# in.
		def require_permission(perm)
			unless user
				session[:go_back] = request.path_info
				redirect to('/login')
			end

			unless authorize(perm)
				raise NotAllowedError, "User lacks required permission token."
			end
		end

		##
		# Generate a unique token and add it to the list of accepted tokens for
		# this session.
		def get_csrf_token
			token = SecureRandom.hex(32)
			session[:csrf_tokens] = [] unless session.has_key?(:csrf_tokens)
			session[:csrf_tokens] << token
			token
		end

		##
		# See if we have a token in the request, and validate it with the set of
		# accepted tokens. Once a token is used, it is consumed.
		def require_valid_csrf_token
			unless session[:csrf_tokens].include? params[:potato]
				raise NotAllowedError, "Invalid session token"
			else
				session[:csrf_tokens].delete params[:potato]
			end
		end

		##
		# HTML helper
		def csrf_token_field
			"<input type='hidden' name='potato' value='#{get_csrf_token}' />"
		end

		##
		# Route helper. Attempt to log in a user via credentials in request
		# parameters.
		def authenticate!
			if u = User[login: params['username']]
				if u.can?(:log_in)
					if u.login? params['password']

						# Give the now logged-in user a brand new session
						session.clear

						# Check for and set up permanent session.
						# One year should be plenty of time to come back.
						if params['remember']
							rand = SecureRandom.hex(32)
							u.update remember_token: rand
							response.set_cookie "remember",
								{value: rand, expires: (Time.now + 365*24*60*60)}
						end

						# Now we're officially logged in!
						session[:user] = u.id

						# See if we have to send him back to where he came from; otherwise,
						# just send him to the frontpage.
						redirect session.has_key?(:go_back) ? session.delete(:go_back) : '/'

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

		def register!
		end
	end
end
