# feature "When using the forums" do
# 	background :all do
# 		@user = create :user, login: "user", password: "password"
# 		create_list :forum_thread, 2, post_count: 2, officer: false
# 		create_list :officer_thread, 2, post_count: 2
# 	end

#   after :all do
#     ForumThread.each { |t| t.remove_all_forum_posts; t.destroy }
#     User.each { |u| u.remove_all_forum_posts; u.destroy}
#     ForumPost.each { |p| p.destroy }
#   end

# 	background :each do
# 		any_instance_of(Application) do |a|
# 			stub(a).user { @user }
# 		end
# 		stub(@user).can? { false }
# 		stub(@user).can?(:view_forum_threads) { true }
# 	end

# 	feature "the index page" do
# 		scenario "shows a list of threads" do
# 			visit "/community/underdogs/forum/"
# 			expect(page).to have_selector("tr.thread", count: 2)
# 		end

# 		scenario "shows officer threads to officers" do
# 			stub(@user).can?(:view_officer_threads) { true }
# 			visit "/community/underdogs/forum/"
# 			expect(page).to have_selector("tr.thread.officer", count: 2)
# 		end
# 	end

# 	feature "the single thread view" do
# 		scenario "finds an existing thread and displays all its posts" do
# 			@thread = ForumThread.first
# 			visit @thread.url
# 			expect(page).to have_text(@thread.title)
# 			expect(page).to have_selector(".ud-post", count: @thread.posts.count)
# 		end

# 		feature "moderation tools" do
# 			scenario "are not displayed for non-moderators" do
# 				@thread = ForumThread.first
# 				visit @thread.url
# 				expect(page).to_not have_selector(".uk-button", text: "Delete")
# 			end

# 			scenario "are displayed for moderators" do
# 				stub(@user).can?(:moderate_forum) { true }
# 				@thread = ForumThread.first
# 				visit @thread.url
# 				expect(page).to have_selector(".uk-button", text: "Delete", count: @thread.posts.count)
# 			end
# 		end

# 		feature "user badges" do
# 			scenario "for a Top Dog are displayed" do
# 				@thread = ForumThread.first
# 				any_instance_of(User) do |u|
# 					stub(u).has_role? { false }
# 					stub(u).has_role?("topdog") { true }
# 				end
# 				visit @thread.url
# 				expect(page).to have_selector(".ud-rank.topdog")
# 			end

# 			scenario "for a Watchdog are displayed" do
# 				@thread = ForumThread.first
# 				any_instance_of(User) do |u|
# 					stub(u).has_role? { false }
# 					stub(u).has_role?("watchdog") { true }
# 				end
# 				visit @thread.url
# 				expect(page).to have_selector(".ud-rank.watchdog")
# 			end

# 			scenario "for an Underdog are displayed" do
# 				@thread = ForumThread.first
# 				any_instance_of(User) do |u|
# 					stub(u).has_role? { false }
# 				end
# 				visit @thread.url
# 				expect(page).to have_selector(".ud-rank.underdog")
# 			end

# 			scenario "only display the highest rank" do
# 				@thread = ForumThread.first
# 				any_instance_of(User) do |u|
# 					stub(u).has_role? { false }
# 					stub(u).has_role?("topdog") { true }
# 					stub(u).has_role?("watchdog") { true }
# 				end
# 				visit @thread.url
# 				expect(page).to have_selector(".ud-rank.topdog")
# 				expect(page).to_not have_selector(".ud-rank.watchdog")
# 				expect(page).to_not have_selector(".ud-rank.underdog")
# 			end

# 			scenario "for an Admin are displayed" do
# 				@thread = ForumThread.first
# 				any_instance_of(User) do |u|
# 					stub(u).has_role? { false }
# 					stub(u).has_role?("admin") { true }
# 				end
# 				visit @thread.url
# 				expect(page).to have_selector(".ud-rank.admin")
# 			end

# 			scenario "for an Admin are displayed alongside others" do
# 				@thread = ForumThread.first
# 				any_instance_of(User) do |u|
# 					stub(u).has_role? { false }
# 					stub(u).has_role?("admin") { true }
# 					stub(u).has_role?("watchdog") { true }
# 				end
# 				visit @thread.url
# 				expect(page).to have_selector(".ud-rank.admin")
# 				expect(page).to have_selector(".ud-rank.watchdog")
# 			end
# 		end
# 	end
# end
