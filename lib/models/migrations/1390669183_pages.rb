Sequel.migration do
	change do
		create_table :pages do
			primary_key :id
			String :path, null: false
		end

		create_table :page_version do
			primary_key :id
			foreign_key :page_id, :pages
			foreign_key :author_id, :users
			String :title, null:false
			String :content, null: false, text: true
			DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
		end
	end
end
