require 'json'

class Application < Sinatra::Base
	namespace '/community/underdogs/forum' do
		get '/?' do
			ensure_user_can :view_forum_threads
			@forums = Forum.visible_for user

			if request.xhr?
				content_type :json
				@threads = @threads.filter(id > params[:from]).limit(params[:count])
				@threads.to_json
			else
				haml :'forum/index'
			end
		end

		get '/:forum/?' do
			ensure_user_can :view_forum_threads
			@forum = Forum[id: params["forum"].to_i]
			ensure_user_can :view_officer_threads if @forum and @forum.officer
			raise Sinatra::NotFound unless @forum

			if request.xhr?
				content_type :json
				@threads = @threads.filter(id > params[:from]).limit(params[:count])
				@threads.to_json
			else
				haml :'forum/view_forum'
			end
		end

		get '/:forum/:thread/?' do
			ensure_user_can :view_forum_threads
			@thread = ForumThread[id: params["thread"].to_i]
			ensure_user_can :view_officer_threads if @thread and @thread.forum.officer
			raise Sinatra::NotFound unless @thread

			haml :'forum/view_thread'
		end

		# post '/:thread/?' do
		# 	# Create a new post in thread :id
		# end

		# get '/:thread/edit/?' do
		# 	# Show  form to edit thread :id and first post
		# end

		# put '/:thread/:comment?' do
		# 	# Update comment :comment in thread :id
		# end

		# get '/new/?' do
		# 	# Show form to create new thread
		# 	ensure_user_can :create_forum_threads

		# 	haml :'forum/new_thread'
		# end

		post '/:forum/?' do
			ensure_user_can :create_forum_threads
			@forum = Forum[id: params["forum"].to_i]
			ensure_user_can :create_officer_threads if @forum and @forum.officer
			raise Sinatra::NotFound unless @forum

			begin
				@thread = ForumThread.create(
					forum: @forum,
					title: params[:thread][:title],
					officer: params[:thread][:officer])

				@thread.add_forum_post(
					author: user,
					forum_thread: @thread,
					content: params[:thread][:content])

				redirect to(@thread.url)

			rescue Sequel::ValidationFailed
				@thread.destroy
				haml :'forum/new_thread'
			end

		end
	end
end
