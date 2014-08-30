Sequel.migration do
	change do

		create_table(:forums) do
			primary_key :id

			String :name
			String :slug
			String :description
			Boolean :officer, default: false
		end

		create_table(:forum_threads) do
			primary_key :id
			foreign_key :forum_id, :forums, on_delete: :cascade

			String :title
			Integer :views
		end

		create_table(:forum_posts) do
			primary_key :id
			foreign_key :user_id, :users
			foreign_key :forum_thread_id, :forum_threads, on_delete: :cascade

			String :content, null: false, text: true
			DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
			DateTime :updated_at
		end

		create_table(:thread_visits) do
			primary_key :id
			foreign_key :user_id, :users, on_delete: :cascade
			foreign_key :forum_thread_id, :forum_threads, on_delete: :cascade
			DateTime :when, default: Sequel::CURRENT_TIMESTAMP
		end

	end
end
