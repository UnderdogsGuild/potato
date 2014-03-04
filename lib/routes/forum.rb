require 'json'

class Application < Sinatra::Base
	namespace '/community/underdogs/forum' do
		get '/?' do
				require_permission :view_forum_threads
				@threads = ForumThread.visible_for user
				if request.xhr?
					content_type :json
					@threads = @threads.filter(id > params[:from]).limit(params[:count])
					@threads.to_json
				else
					haml :'forum/index'
				end
		end

		get '/:id-*/?' do
			@thread = ForumThread[id: params[:id]]
			require_permission :view_officer_threads if @thread and @thread.officer
			raise NotFound unless @thread

			haml :'forum/view_thread'
		end

		get '/new/?' do
			require_permission :create_forum_threads

			haml :'forum/new_thread'
		end

		post '/new/?' do
			require_permission :create_forum_threads
			require_permission :create_officer_threads if params[:thread][:officer]

			@thread = ForumThread.new
			@thread.title = params[:thread][:title]
			@thread.officer = params[:thread][:officer]

			if @thread.valid?
				@thread.save
				@post = ForumPost.new
				@post.author = user
				@post.forum_thread = @thread
				@post.content = params[:thread][:content]

				if @post.valid?
					@post.save

				else
					haml :'forum/new_thread'
				end

			else
				haml :'forum/new_thread'
			end

		end
	end
end
