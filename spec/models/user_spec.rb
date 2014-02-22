describe User do
	##
	# Models are loaded before the migrations are run, so we need to refresh the
	# dataset to get our accessor methods.
	before :all do
		 User.dataset = User.dataset
		 Permission.dataset = Permission.dataset
		 Role.dataset = Role.dataset
	end

	before :each do
		@u = User.create login: "mkaito", password: "doomimpending"
		@p = Permission.create label: "create_world",
			description: "Can create the world"
		@r = Role.create label: "God", description: "Is omnipotent"
		@root = Role.create label: "root", root: true
	end

	it "creates the test user successfully" do
		expect(User.first).to_not be_nil
	end

	it "can create and verify roles and permissions" do
		@r.permissions << @p
		@u.roles << @r

		expect(@u.can?(:create_world)).to be_true
		expect(@u.can?(:read_newspaper_in_the_toilet)).to be_false
	end

	it "should recognize root's power" do
		 @u.roles << @root

		 expect(@u.can?(:create_apes)).to be_true
	end

	it "should hash the password field" do
		 expect(@u.password_hash).to_not eq("doomimpending")
	end

	it "should return an instance of BCrypt::Password on read" do
		 expect(@u.password).to be_an_instance_of(BCrypt::Password)
	end

	it "should allow to compare the hashed password" do
		 expect(BCrypt::Password.new(@u.password_hash)).to eq("doomimpending")
	end

	it "should return the user object on successful authentication" do
		 expect(User.first.login?("doomimpending").id).to eq(User.first.id)
	end

	it "should return nil on failed authentication" do
		 expect(User.first.login?("notmypassword")).to be_nil
	end
end
