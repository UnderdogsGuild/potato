class Application < Sinatra::Base

	get '/' do
		haml :'pages/index'
	end

	get '/community/linkshells/doomfinders' do
		haml :'pages/community/linkshells/doomfinders'
	end

	get '/tmp/login' do
		haml :'views/login'
	end
end
