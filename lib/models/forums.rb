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
	one_to_many :forum_posts, after_add: :after_add_post
	many_to_many :tags

	one_to_many :visits
	one_to_many :stars
	
	# Convenience aliases
	alias_method :posts, :forum_posts
	alias_method :add_post, :add_forum_post
	alias_method :remove_post, :remove_forum_post
	alias_method :remove_all_posts, :remove_all_forum_posts

	# Default ordering: as last bumped
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

	# {{{ Tags
	# Add a tag by name
	# alias_method :_add_tag, :add_tag
	def add_tag_by_name(tname)
		t = Tag.first(name: tname)
		return nil unless t
		self.add_tag(t)
	end

	##
	# Remove a tag by name
	def remove_tag_by_name(tname)
		t = self.tags_dataset.first(name: tname)
		return nil unless t
		self.remove_tag(t)
	end

	##
	# Return all threads tagged with a given tag name, or [] if given invalid
	# tag names.
	# TODO: Return useful information when things go wrong
	def self.by_tag_names (*tns)
		tags = tns.map { |tn| Tag.first(name: tn) }
		return [] if tags.any?(&:nil?)

		filter = tags.map { |t| [:tags, t] }
		self.where(filter).all
	end
	# }}}
	# {{{ Read tracking
	
	##
	# Bump the thread when adding a new post
	def after_add_post p
		update updated_at: p.updated_at
		# bump
	end

	##
	# Update modification timestamp to now.
	def bump
		update updated_at: Time.now
	end

	##
	# Visit a thread, update timestamps.
	def visit(user)
		if v = self.visit_for(user)
			v.update when: Time.now

		else
			self.add_visit user: user

		end
	end

	##
	# Return the relevant visit object for a thread and user
	def visit_for(user)
		self.visits_dataset.first(user: user)
	end

	##
	# Returns the first post created after the last visit of a user
	def first_new_post_for(user)
		if v = self.visit_for(user)
			self.forum_posts_dataset.first { created_at > v.when } or self.forum_posts_dataset.last
		else
			self.post
		end
	end

	##
	# Returns true if the thread contains posts created since the last time the
	# user viewed the thread
	def updated_for?(user)
		if v = self.visit_for(user)
			updated_at > v.when
		else
			updated_at < Date.today - 30
		end
	end

	##
	# Retrieve all threads with new content for a given user
	def self.updated_for(user)
		# Limit fields to those present in the forum_threads table,
		self.select(:forum_threads__id, :title, :slug, :views, :updated_at, :officer, :deleted).

		# perform left join on visits (includes threads with no visits),
			left_join(:visits, forum_thread_id: :id).

		# limit dataset to visits for given user and filter for threads updated since last visit,
			where { Sequel.&({visits__user_id: user.id},
											(forum_threads__updated_at > visits__when))}.

		# include threads with no visits, but onlt those updated within 30 days.
			or    { Sequel.&({visits__user_id: nil},
											(forum_threads__updated_at > Date.today - 30))}
	end
	# }}}
	# {{{ Stars
	
	##
	# Add a star for user and thread
	def star_for(user)
		self.stars_dataset.first(user: user) or self.add_star(user: user)
	end

	##
	# Check whether a thread is starred for a user
	def starred_for?(user)
		! self.stars_dataset.first(user: user).nil?
	end

	##
	# Retrieve all starred threads for a given user
	def self.starred_for(user)
		# Limit fields to those present in the forum_threads table,
		self.select(:forum_threads__id, :title, :slug, :views, :updated_at, :officer, :deleted).

			# perform an inner join on stars and users,
			join(Star, forum_thread_id: :id).
			join(User, id: :user_id).

			# limit dataset to stars for given user.
			where(stars__user_id: user.id)
	end

	# }}}
	# {{{ Search frontend

	# Split the query on whitespace, filter words into @tags, %states, or terms.
	# Feed terms to fulltext for the primary result set.
	# If no terms, attempt to treat states as terms for special search.
	# If no terms and no states, get the entire thread set.
	# Apply tags as filter to the set.
	def self.search(qstring, user)
		tags = []
		terms = []
		states = []

		qstring.split.each do |term|
			if term[0] == '@'
				tags << term[1..-1]
			elsif term[0] == '%'
				states << term[1..-1]
			else
				terms << term
			end
		end

		tagged = self.by_tag_names(*tags) unless tags.empty?

		unless terms.empty?
			texted = ForumPost.dataset.full_text_search(:content, terms).all
			texted.map! { |p| p.thread }
			texted.uniq!
		end
		
		threads = if not tagged.nil? and not texted.nil?
			tagged & texted
		elsif not tagged.nil?
			tagged
		elsif not texted.nil?
			texted
		elsif tags.empty? and terms.empty?
			ForumThread.all
		else
			[]
		end

		if states.include?('starred')
			threads.select! { |t| t.starred_for?(user) }
		end

		if states.include?('unread')
			threads.select! { |t| t.updated_for?(user) }
		end

		threads
	end
	# }}}
end

##
# Post model
#
# Holds the content and authorship data for a post, as well as timestamps.
class ForumPost < Sequel::Model
	plugin :validation_helpers
	plugin :timestamps, update_on_create: true

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

class Tag < Sequel::Model
	plugin :validation_helpers
	many_to_many :forum_threads

	def html_tag
		"<span style='color: ##{self.color}'>#{self.name}</span>"
	end

	def validate
		super
		validates_presence :name
		validates_unique :name

		validates_presence :color
		validates_unique :color
	end
end

class Visit < Sequel::Model
	many_to_one :user
	many_to_one :forum_thread
end

class Star < Sequel::Model
	many_to_one :user
	many_to_one :forum_thread
end 

# vim:fdm=marker
