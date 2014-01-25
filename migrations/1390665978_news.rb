Sequel.migration do
	change do
		 create_table :newsentries do
			  primary_key :id
				foreign_key :author, :users
				String :title, null: false
				String :content, text: true
				String :slug, null: false
				DateTime :published_at, default: Sequel::CURRENT_TIMESTAMP
				Boolean :published, default: true
		 end
	end
end
