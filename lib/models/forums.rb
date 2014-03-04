class ForumThread < Sequel::Model
	one_to_many :forum_posts, class: :ForumPost
	alias_method :posts, :forum_posts

	def self.visible_for(user)
		return [] unless user.can? :view_forum_threads
		if user.can? :view_officer_threads
			return self.all
		else
			return self.where(officer: false)
		end
	end

	def post
		self.posts.first
	end

	def author
		post.author
	end

	def content
		post.content
	end

	def url
		"/community/underdogs/forum/#{self.id}-#{self.title.to_url}"
	end

	def as_json
		{
			title: self.title,
			author: self.posts.first.author.as_json,
			officer: self.officer,
			url: self.url,
			views: self.views,
			last: self.posts.last.as_json,
			created_at: self.created_at,
		}
	end

	def to_json(*args)
		as_json.to_json(*args)
	end
end

class ForumPost < Sequel::Model
	many_to_one :author, key: :author_id, class: :User
	many_to_one :forum_thread, class: :ForumThread
	alias_method :thread, :forum_thread

	def before_save
		self.updated_at = Time.now
	end

	def is_thread_opener?
		self.thread.posts.first.id == self.id
	end

	def as_json
		{
			author: self.author.as_json,
			is_op: self.is_thread_opener?,
			content: self.content,
			updated_at: self.updated_at,
			posted_at: self.posted_at
		}
	end

	def to_json(*args)
		as_json.to_json(*args)
	end
end
