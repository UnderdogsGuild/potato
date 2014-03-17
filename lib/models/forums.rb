class ForumThread < Sequel::Model
  plugin :validation_helpers

	one_to_many :forum_posts, class: :ForumPost
	alias_method :posts, :forum_posts

  def validate
    super
    validates_presence :title
  end

	def self.visible_for(user)
		return [] unless user.can? :view_forum_threads
		if user.can? :view_officer_threads
			return all
		else
			return where(officer: false)
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
		"/community/underdogs/forum/#{id}-#{title.to_url}"
	end

	def as_json
		{
			title: title,
			author: posts.first.author.as_json,
			officer: officer,
			url: url,
			views: views,
			last: posts.last.as_json,
			created_at: created_at,
		}
	end

	def to_json(*args)
		as_json.to_json(*args)
	end
end

class ForumPost < Sequel::Model
  plugin :validation_helpers

	many_to_one :author, key: :author_id, class: :User
	many_to_one :forum_thread, class: :ForumThread
	alias_method :thread, :forum_thread

  def validate
    super
    validates_presence :content
  end

	def before_save
		set(updated_at: Time.now)
	end

	def is_thread_opener?
		thread.posts.first.id == id
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

	def to_json(*args)
		as_json.to_json(*args)
	end
end
