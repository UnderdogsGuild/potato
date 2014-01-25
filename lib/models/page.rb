class Page < Sequel::Model
	one_to_many :page_versions
	
	def url
		self[:slug]
	end

	def current_version
		page_versions.order(:id).last
	end
end

class PageVersion < Sequel::Model
	many_to_one :page
	many_to_one :author, key: :author_id, class: :User
end
