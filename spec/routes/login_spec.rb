feature "Auth routes" do
	feature '/login' do
		background :each do
			@uactive = create(:user, login: "active", password: "doomimpending")
			@uinactive = create(:user, login: "inactive", password: "alreadydoomed")

			@plogin = Permission.create label: "log_in", description: "Can log in"
			@rmember = Role.create label: "Member", description: "Active members"

			@rmember.add_permission @plogin
			@uactive.add_role @rmember
		end

		scenario "logging in and out" do
			visit '/login'
			expect(page).to_not have_content("Welcome, active!")

			within ".ud-mainpage form" do
				fill_in 'username', with: "active"
				fill_in 'password', with: 'doomimpending'
				check "remember"
				click_button 'Login!'
			end

			expect(page).to_not have_selector('.ud-mainpage .uk-alert')
			expect(page).to have_content("Welcome, active!")
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
end
