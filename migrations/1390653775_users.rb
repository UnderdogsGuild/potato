Sequel.migration do
	change do
		create_table(:users) do
			primary_key :id
			String :login, null: false
			String :password, null: false
			DateTime :last_login, default: Sequel::CURRENT_TIMESTAMP
		end

		create_table(:roles) do
			primary_key :id
			String :label, null: false
			String :description
			Boolean :root
		end

		create_table(:permissions) do
			primary_key :id
			String :label, null: false
			String :description
		end

		create_join_table users_id: :users, role_id: :roles
		create_join_table role_id: :roles, permission_id: :permissions
		create_join_table user_id: :users, permission_id: :permissions
	end
end
