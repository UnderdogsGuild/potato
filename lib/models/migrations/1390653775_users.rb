Sequel.migration do
	change do
		create_table(:users) do
			primary_key :id
			String :login, null: false
			String :password_hash, length: 60, null: false
			String :email, length: 255, null: false
			String :remember_token, length: 64
			Boolean :legacy, default: false
			DateTime :last_login
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

		create_join_table role_id: :roles, user_id: :users 
		create_join_table permission_id: :permissions, role_id: :roles
		create_join_table permission_id: :permissions, user_id: :users
	end

	# down do
	# 	drop_table :roles_users
	# 	drop_table :permissions_roles
	# 	drop_table :permissions_users
	# 	drop_table :permissions
	# 	drop_table :roles
	# 	drop_table :users
	# end
end
