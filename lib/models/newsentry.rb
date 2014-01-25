class NewsEntry < Sequel::Model
	many_to_one :author, class: :User
	
	def self.all_published
		self[published: true]
	end
end
