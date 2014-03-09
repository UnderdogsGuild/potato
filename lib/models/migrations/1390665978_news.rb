Sequel.migration do
	change do
		 create_table :news_entries do
			  primary_key :id
				foreign_key :author, :users, on_delete: :cascade
				String :title, null: false
				String :content, text: true
				String :url, null: false
				DateTime :published_at, default: Sequel::CURRENT_TIMESTAMP
				Boolean :published, default: true
		 end
	end
end
