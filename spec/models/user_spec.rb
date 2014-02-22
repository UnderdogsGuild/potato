describe User do
	before :each do
		@umember = User.create login: "member", password: "doomimpending"
		@uroot = User.create login: "root", password: "thesecret"

		@plogin = Permission.create label: "log_in",
			description: "Can log in"
		@psecond = Permission.create label: "second_perm",
			description: "Second permission"
		@rmembers = Role.create label: "God", description: "Is omnipotent"
		@rroot = Role.create label: "root", root: true

		@rmembers.add_permission @plogin
		@umember.add_role @rmembers
		@umember.add_permission @psecond

		@uroot.add_role @rroot
	end

	it "creates the test user successfully" do
		expect(User.first).to_not be_nil
	end

	it "associates roles to users" do
		expect(User.first.roles).to_not be_empty
	end

	it "associates permissions to roles" do
		expect(Role.first.permissions).to_not be_empty
	end

	it "associates permissions to users" do
		expect(User.first.permissions).to_not be_empty
	end

	it "aggregates all available permissions for a user" do
		expect(User.first._perms.length).to eq(2)
	end

	it "can verify permissions on users" do
		expect(@umember.can?(:log_in)).to be_true
		expect(@umember.can?(:read_newspaper_in_the_toilet)).to be_false
	end

	it "should recognize root's power" do
		 expect(@uroot.can?(:create_apes)).to be_true
	end

	it "should hash the password field" do
		 expect(@umember.password_hash).to_not eq("doomimpending")
	end

	it "should return an instance of BCrypt::Password on read" do
		 expect(@umember.password).to be_an_instance_of(BCrypt::Password)
	end

	it "should allow to compare the hashed password" do
		 expect(BCrypt::Password.new(@umember.password_hash)).to eq("doomimpending")
	end

	it "should return the user object on successful authentication" do
		 expect(User.first.login?("doomimpending").id).to eq(User.first.id)
	end

	it "should return nil on failed authentication" do
		 expect(User.first.login?("notmypassword")).to be_nil
	end
end
