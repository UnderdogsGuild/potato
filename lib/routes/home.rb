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
end
