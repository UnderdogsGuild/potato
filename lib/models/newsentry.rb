class NewsEntry < Sequel::Model
	many_to_one :author, class: :User

	def before_save
		self[:url] = self[:title].to_url
	end
	
	def self.all_published
		where(published: true)
	end
end
