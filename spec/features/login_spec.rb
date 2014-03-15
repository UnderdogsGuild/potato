feature 'Authentication', js: true do
	background :all do
		@uactivepass = Digest::SHA2.new(512).update("doomimpending").to_s
		@uinactivepass = Digest::SHA2.new(512).update("alreadydoomed").to_s

		@uactive = create :user, login: "active", password: @uactivepass
		@uinactive = create :user, login: "inactive", password: @uinactivepass

		@plogin = create :permission, label: "log_in"
		@rmember = create :role, label: "Member"

		@rmember.add_permission @plogin
		@uactive.add_role @rmember
	end

	after :all do
		@rmember.remove_all_permissions
		@uactive.remove_all_roles
		@plogin.remove_all_roles

		@plogin.destroy
		@rmember.destroy

		@uinactive.destroy
		@uactive.destroy
	end

	scenario "logging in" do
		visit '/login'

		# Make sure we are not logged in yet
		expect(page).to_not have_selector(".user-active")

		# Fill the login form and go for it
		within ".ud-mainpage form" do
			fill_in 'username', with: "active"
			fill_in 'password', with: "doomimpending"
			#check "remember"
			click_button 'Login!'
		end

		# Make sure we encountered no errors
		expect(page).to_not have_selector('.wrongpass')
		expect(page).to_not have_selector('.banned')

		# Make sure the system recognizes us now
		expect(page).to have_selector(".user-active")
	end

	scenario "logging out" do
		visit '/login'
		expect(page).to_not have_selector(".user-active")
		within ".ud-mainpage form" do
			fill_in 'username', with: "active"
			fill_in 'password', with: "doomimpending"
			check "remember"
			click_button 'Login!'
		end
		expect(page).to have_selector(".user-active")
		visit '/logout'
		expect(page).to_not have_selector(".user-active")
	end

	scenario "logging in as inactive user" do
		visit '/login'
		within ".ud-mainpage form" do
			fill_in 'username', with: "inactive"
			fill_in 'password', with: "alreadydoomed"
			check "remember"
			click_button 'Login!'
		end
		expect(page).to have_selector('.banned')
	end

	scenario "logging in as nonexistant user" do
		visit '/login'
		within ".ud-mainpage form" do
			fill_in 'username', with: "nonexistant"
			fill_in 'password', with: 'supersecret'
			check "remember"
			click_button 'Login!'
		end
		expect(page).to have_selector('.wrongpass')
	end

	scenario "logging in with an incorrect password" do
		visit '/login'
		within ".ud-mainpage form" do
			fill_in 'username', with: "active"
			fill_in 'password', with: 'notmypassword'
			check "remember"
			click_button 'Login!'
		end
		expect(page).to have_selector('.wrongpass')
	end

end
