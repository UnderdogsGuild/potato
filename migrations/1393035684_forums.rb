Sequel.migration do
	change do
		create_table(:forum_threads) do
			primary_key :id
			String :title, null: false
			DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
		end

		create_table(:forum_posts) do
			primary_key :id
			foreign_key :author_id, :users
			foreign_key :forum_thread_id, :forum_threads
			DateTime :posted_at, default: Sequel::CURRENT_TIMESTAMP
			DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
			String :content, null: false, text: true
		end
	end
end
