feature 'Authentication', js: true do
	background :all do
		@uactive = create :user, login: "active", password: "doomimpending"
		@uinactive = create :user, login: "inactive", password: "alreadydoomed"

		@plogin = create :permission, label: "log_in"
		@rmember = create :role, label: "Member"

		@rmember.add_permission @plogin
		@uactive.add_role @rmember
	end

	scenario "logging in" do
		visit '/login'

		# Make sure we are not logged in yet
		expect(page).to_not have_content("Welcome, active!")

		# Fill the login form and go for it
		within ".ud-mainpage form" do
			fill_in 'username', with: "active"
			fill_in 'password', with: 'doomimpending'
			#check "remember"
			click_button 'Login!'
		end

		# Make sure we encountered no errors
		expect(page).to_not have_selector('.ud-mainpage .uk-alert')

		#expect(page).to_not have_text("Login Sign In Remember Me Login!")

		# Make sure the system recognizes us now
		expect(page).to have_selector(".user-active")
	end

	scenario "logging out" do
		visit '/login'
		within ".ud-mainpage form" do
			fill_in 'username', with: "active"
			fill_in 'password', with: 'doomimpending'
			check "remember"
			click_button 'Login!'
		end
		visit '/logout'
		expect(page).to_not have_content("Welcome, active!")
	end

	scenario "logging in as inactive user" do
		visit '/login'
		within ".ud-mainpage form" do
			fill_in 'username', with: "inactive"
			fill_in 'password', with: 'alreadydoomed'
			check "remember"
			click_button 'Login!'
		end
		expect(page).to have_selector('.ud-mainpage .uk-alert', text: "Unfortunately, we can't let you in.")
	end

	scenario "logging in as nonexistant user" do
		visit '/login'
		within ".ud-mainpage form" do
			fill_in 'username', with: "nonexistant"
			fill_in 'password', with: 'supersecret'
			check "remember"
			click_button 'Login!'
		end
		expect(page).to have_selector('.ud-mainpage .uk-alert', text: 'The UnderdogsID and password you entered are incorrect.')
	end

	scenario "logging in with an incorrect password" do
		visit '/login'
		within ".ud-mainpage form" do
			fill_in 'username', with: "active"
			fill_in 'password', with: 'notmypassword'
			check "remember"
			click_button 'Login!'
		end
		expect(page).to have_selector('.ud-mainpage .uk-alert', text: 'The UnderdogsID and password you entered are incorrect.')
	end

end
