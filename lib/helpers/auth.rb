class Application < Sinatra::Base
	helpers do
		def require_permission(perm)
			if session[:user].nil?
				redirect to('/login')
			end

			unless session[:user].can?(perm)
				halt 403
			end
		end
	end
end
