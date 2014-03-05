feature "/community/underdogs/forum" do
	background :all do
		@user = create :user, login: "user", password: "password"
		create_list :forum_thread, 2, post_count: 2, officer: false
		create_list :officer_thread, 2, post_count: 2
	end

	before :each do
		any_instance_of(Application) do |a|
			stub(a).user { @user }
		end
		stub(@user).can?(:view_forum_threads) { true }
	end

	feature "index" do
		scenario "shows a list of threads" do
			stub(@user).can?(:view_officer_threads) { false }

			visit "/community/underdogs/forum/"
			expect(page).to_not have_text("I'm afraid there are no threads for you")
			expect(page).to have_selector("tr.thread", count: 2)
		end

		scenario "shows officer threads to officers" do
			stub(@user).can?(:view_officer_threads) { true }

			visit "/community/underdogs/forum/"
			expect(page).to have_selector("tr.thread", count: 4)
			expect(page).to have_selector("tr.thread.officer", count: 2)
		end
	end

	feature "thread view" do
		scenario "finds an existing thread" do
			@thread = ForumThread.first
			visit @thread.url
		end
	end
end
