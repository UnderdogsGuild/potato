class Application < Sinatra::Base
	namespace :forum do
		get '/' do
			@threads = ForumThreads.all
		end
	end
end
