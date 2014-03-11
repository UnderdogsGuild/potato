class Application < Sinatra::Base

	get '/' do
		haml :'pages/index'
	end

	#get '/community/linkshells/doomfinders' do
		#@sass_pallet='/css/df_master.css'
		#haml :'pages/community/linkshells/doomfinders'
	#end

	get '/donate/success' do
		haml :'pages/donate/success'
	end

	get '/donate/cancel' do
		haml :'pages/donate/cancel'
	end

	get '/tmp/403' do
		haml :'pages/errors/403', layout: :errors		
	end

	get '/tmp/new_post'
		haml :'forum/new_post'
	end

	get '/tmp/new_thread'
		haml :'forum/new_thread'
	end

	get '/tmp/edit_post'
		haml :'forum/edit_post'
	end
end
