class ForumThread < Sequel::Model
	one_to_many :forum_posts
end

class ForumPost < Sequel::Model
	many_to_one :author, key: :author_id, class: :User
	many_to_one :forum_thread

	def before_save
		self.updated_at = Time.now
	end
end
