##
# Forum related models
##

##
# Forum thread model
#
# Groups posts, and holds metadata such as whether a thread is marked as
# deleted, or as officer only.
class ForumThread < Sequel::Model
	plugin :validation_helpers

	# many_to_one :forum
	one_to_many :forum_posts
	
	# Convenience aliases
	alias_method :posts, :forum_posts
	alias_method :add_post, :add_forum_post
	alias_method :remove_post, :remove_forum_post
	alias_method :remove_all_posts, :remove_all_forum_posts

	# Default ordering
	self.dataset = self.dataset.order(Sequel.desc(:updated_at))

	def validate
		super
		validates_presence :title
	end

	##
	# Automatically build a slug if none has been provided
	def before_save
		self.slug ||= self.title.to_url
		super
	end

	##
	# Build the url for a thread
	def url
		"/community/underdogs/forum/#{self.id}-#{self.slug}"
	end

	##
	# Filter posts as apropriate for active user
	def self.visible_for(user)

		# Nothing to see here
		return [] unless user.can? :view_forum_threads

		# Assuming the user can view threads at all...
		filter = {}

		# If he can't see deleted threads...
		unless user.can? :view_deleted_threads then
			filter[:deleted] = false
		end

		# If he can't see officer threads...
		unless user.can? :view_officer_threads then
			filter[:officer] = false
		end

		return self.where(filter)
	end

	##
	# Build an array of @thread.posts to display for the current user.
	def posts_visible_for(user)
		# If we're calling this, then the user can view regular threads, at the
		# very least, which means that viewing non-deleted posts is fine by
		# default.
		filter = {}

		# Regular users can't view deleted posts, though.
		unless user.can? :view_deleted_posts then
			filter[:deleted] = false
		end

		return self.forum_posts_dataset.where(filter)
	end

	def add_post(pdata)
		new_p = self.add_forum_post(pdata)
		self.update(updated_at: new_p.updated_at)
		return new_p
	end

	##
	# Convenience method to get the first post in the thread
	def post
		self.posts.first
	end

	##
	# Delegate to first post for author
	def author
		post.user
	end

	##
	# Delegate to first post for content
	def content
		post.content
	end

	# def as_json
	# 	{
	# 		title: title,
	# 		author: author.as_json,
	# 		officer: officer,
	# 		url: url,
	# 		views: views,
	# 		last: posts.last.as_json,
	# 		created_at: created_at,
	# 	}
	# end
end

##
# Post model
#
# Holds the content and authorship data for a post, as well as timestamps.
class ForumPost < Sequel::Model
	plugin :validation_helpers
	plugin :timestamps

	# Posts belong to a user
	many_to_one :user
	alias_method :author, :user

	# and to a thread
	many_to_one :forum_thread
	alias_method :thread, :forum_thread
	

	def validate
		super
		validates_presence :content
	end

	##
	# Check if the current post is the first in its thread.
	def is_thread_opener?
		self.thread.posts.first.equal? self
	end

	##
	# Build on the parent thread's url to add an anchor for the current post.
	def url
		"#{self.thread.url}##{self.html_id}"
	end

	##
	# Build the correct html ID string for the current post.
	def html_id
		"post-#{self.id}"
	end

	##
	# Build a string of apropriate css classes for the current post, as a string
	# ready for insertion in HTML.
	def html_classes
		classes = []

		if author.has_role? "topdog"
			classes << "ud-post-td"

		elsif author.has_role? "watchdog"
			classes << "ud-post-wd"

		else
			classes << "ud-post-ud"
		end

		classes.join " "
	end

	# def as_json
	# 	{
	# 		author: author.as_json,
	# 		is_op: is_thread_opener?,
	# 		content: content,
	# 		updated_at: updated_at,
	# 		posted_at: posted_at
	# 	}
	# end
end
