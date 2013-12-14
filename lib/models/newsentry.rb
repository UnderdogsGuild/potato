class NewsEntry
	include DataMapper::Resource
	
	property :id, Serial
	property :title, String
	property :tagline, String
	property :slug, String
	property :content, Text
	property :published, Boolean, :default => false
	property :publish_on, Date

	def self.all_published
		all :published => true
	end
end
