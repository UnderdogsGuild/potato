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

	def author
		self.posts.first.author
	end

	def url
		"/community/underdogs/forum/#{self.id}-#{self.title.to_url}"
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
end
