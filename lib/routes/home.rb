class Application < Sinatra::Base

	get '/' do
		haml :'pages/index'
	end

	get '/community/linkshells/doomfinders' do
		@sass_pallet='/css/df_master.css'
		haml :'pages/community/linkshells/doomfinders'
	end

	get '/community/underdogs/forum' do
		haml :'pages/community/underdogs/forum'
	end

	get '/tmp/login' do
		haml :'views/login'
	end

	get '/tmp/new_thread' do
		haml :'views/new_thread'
	end

	get '/donate/success' do
		haml :'pages/donate/success'
	end

	get '/donate/cancel' do
		haml :'pages/donate/cancel'
	end

	get '/tmp/view_thread' do
		haml :'views/view_thread'
	end
end
