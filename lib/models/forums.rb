class Forum < Sequel::Model
	plugin :validation_helpers

	one_to_many :forum_threads
	alias_method :threads, :forum_threads

	def validate
		super
		validates_presence :name
		validates_presence :description
	end

	def url
		"/community/underdogs/forum/#{name.to_url}"
	end

	def self.visible_for(user)
		return [] unless user.can? :view_forum_threads
		if user.can? :view_officer_forums
			return all
		else
			return where(officer: false)
		end
	end

end

class ForumThread < Sequel::Model
	plugin :validation_helpers

	many_to_one :forum
	one_to_many :forum_posts
	alias_method :posts, :forum_posts

	def validate
		super
		validates_presence :title
	end

	def url
		"#{forum.url}/#{id}-#{title.to_url}"
	end

	# Pretend the content of the first post is part of the thread, so we can
	# treat the thread and first post more or less interchangeably.
	def post
		self.posts.first
	end

	def author
		post.user
	end

	def content
		post.content
	end

	def as_json
		{
			title: title,
			author: author.as_json,
			officer: officer,
			url: url,
			views: views,
			last: posts.last.as_json,
			created_at: created_at,
		}
	end
end

class ForumPost < Sequel::Model
	plugin :validation_helpers
	plugin :timestamps

	many_to_one :user
	alias_method :author, :user

	many_to_one :forum_thread
	alias_method :thread, :forum_thread
	

	# many_to_one :parent, class: self
	# one_to_many :children, key: :parent_id, class: self

	def validate
		super
		validates_presence :content
	end

	def is_thread_opener?
		thread.posts.first.equal? self
	end

	def url
		"#{thread.url}##{html_id}"
	end

	def html_id
		"post-#{id}"
	end

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

	def as_json
		{
			author: author.as_json,
			is_op: is_thread_opener?,
			content: content,
			updated_at: updated_at,
			posted_at: posted_at
		}
	end
end
