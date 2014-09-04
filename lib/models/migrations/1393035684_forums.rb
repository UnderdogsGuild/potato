Sequel.migration do
	change do

		create_table(:forum_threads) do
			primary_key :id

			String :title, null: false
			String :slug, null: false
			Integer :views, default: 1
			DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP

			Boolean :officer, default: false
			Boolean :deleted, default: false
		end

		create_table(:forum_posts) do
			primary_key :id
			foreign_key :user_id, :users
			foreign_key :forum_thread_id, :forum_threads, on_delete: :cascade

			String :content, null: false, text: true, full_text: true
			DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
			DateTime :updated_at

			Boolean :deleted, default: false
		end

		create_table(:tags) do
			primary_key :id
			String :name, null: false, unique: true
			String :color, null: false, unique: true, size: 6
		end

		create_join_table forum_thread_id: :forum_threads, tag_id: :tags

		# create_table(:thread_visits) do
		# 	primary_key :id
		# 	foreign_key :user_id, :users, on_delete: :cascade
		# 	foreign_key :forum_thread_id, :forum_threads, on_delete: :cascade
		# 	DateTime :when, default: Sequel::CURRENT_TIMESTAMP
		# end

	end
end
