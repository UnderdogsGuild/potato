class Page
	include DataMapper::Resource
	
	property :id, Serial
	property :title, String
	property :content, Text
	property :slug, String, :default => lambda { |page, slug| page.title.to_url}

	def url
		attribute_get(:slug)
	end
end
