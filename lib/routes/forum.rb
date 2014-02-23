class Application < Sinatra::Base
	namespace :forum do
		get '/' do
			require_permission :view_forum_thread
			@threads = ForumThreads.all
		end
	end
end
