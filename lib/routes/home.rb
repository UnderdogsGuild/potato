class Application < Sinatra::Base

	get '/' do
		haml :'pages/index'
	end

	get '/community/linkshells/doomfinders' do
		@sass_pallet='/css/df_master.css'
		haml :'pages/community/linkshells/doomfinders'
	end

	get '/tmp/login' do
		haml :'views/login'
	end

	not_found do
		haml :'pages/errors/404', :layout => :'errors'
	end

end
