describe User do
	before :all do
		@password = Faker::Internet.password
		@umember = create(:user, password: @password)
		@uroot = create(:user)

		@rmembers = create(:role, label: "members")

		@rmembers.add_permission( create(:permission, label: "log_in") )
		@umember.add_role @rmembers
		@umember.add_permission( create(:permission) )

		@uroot.add_role( create(:role, label: "admins", root: true) )
	end

	after :all do
		Permission.each { |p| p.remove_all_roles; p.remove_all_users; p.destroy }
		Role.each { |r| r.remove_all_users; r.remove_all_permissions; r.destroy }
		User.each { |u| u.remove_all_roles; u.remove_all_permissions; u.destroy }
	end

	it "associates roles to users" do
		expect(@umember.roles).to_not be_empty
	end

	it "associates permissions to roles" do
		expect(@rmembers.permissions).to_not be_empty
	end

	it "associates permissions to users" do
		expect(@umember.permissions).to_not be_empty
	end

	it "aggregates all available permissions for a user" do
		expect(@umember._perms.length).to eq(2)
	end

	it "can verify permissions on users" do
		expect(@umember.can?(:log_in)).to be_truthy
		expect(@umember.can?(:read_newspaper)).to be_falsey
	end

	it "should recognize root's power" do
		expect(@umember._is_root?).to be_falsey
		expect(@uroot._is_root?).to be_truthy
		expect(@umember.can?(:create_apes)).to be_falsey
		expect(@uroot.can?(:create_apes)).to be_truthy
	end

	it "should hash the password field" do
		 expect(@umember.password_hash).to_not eq(@password)
	end

	it "#password should return an instance of BCrypt::Password" do
		 expect(@umember.password).to be_an_instance_of(BCrypt::Password)
	end

	it "should allow to compare the hashed password" do
		 expect(BCrypt::Password.new(@umember.password_hash)).to eq(@password)
	end

	it "should return the user object on successful authentication" do
		 expect(@umember.login?(@password)).to equal(@umember)
	end

	it "should return nil on failed authentication" do
		 expect(User.first.login?(Faker::Internet.password)).to be_nil
	end
end
