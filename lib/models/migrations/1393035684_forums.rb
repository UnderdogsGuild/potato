Sequel.migration do
	change do
		create_table(:posts) do
			primary_key :post_id
			foreign_key :author_id, :users
      foreign_key :parent_id, :posts
			DateTime :posted_at, default: Sequel::CURRENT_TIMESTAMP
			DateTime :updated_at
      Boolean :officer_only
			String :content, null: false, text: true
      String :title
		end
	end
end
