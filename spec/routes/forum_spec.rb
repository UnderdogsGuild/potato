describe '/community/underdogs/forum/' do
	let(:forum_path) { "/community/underdogs/forum" }
	let(:csrf) { SecureRandom.hex(32) }

	before :all do
		@user = create :user

		@forum = create :forum
		@thread = @forum.threads.first
		@post = @thread.posts.first

		@officer_forum = create :forum, officer: true
		@officer_thread = @officer_forum.threads.first
		@officer_post = @officer_thread.posts.first
	end

	after :all do
		Forum.each { |f| f.destroy }

		Permission.each { |p| p.remove_all_users; p.remove_all_roles; p.destroy }
		Role.each { |r| r.remove_all_users; r.remove_all_permissions; r.destroy }
		User.each { |u| u.remove_all_roles; u.remove_all_permissions; u.destroy }
	end

	before :each do
		any_instance_of(Application) { |a| stub(a).user { @user } }
		stub(@user).can? { false }
	end

	describe 'forum index' do
		describe "for a registered user" do
			before :each do
				stub(@user).can?(:view_forum_threads) { true }
				get forum_path
			end

			it "does not return an error" do
				expect(last_response).to be_ok
			end
		end # for a registered user

		describe "for a guest" do
			before :each do
				@user = nil
				get forum_path
			end

			it "returns a redirect" do
				expect(last_response).to be_redirect
			end

			it "redirects to the login page" do
				expect(last_response.location).to eq("http://example.org/login")
			end
		end # for a guest
	end # forum index

	describe "/forum" do
		describe "for a registered user" do
			before :each do
				stub(@user).can?(:view_forum_threads) { true }
				get @forum.url
			end

			it "does not return an error" do
				expect(last_response).to be_ok
			end
		end
	end
end
# describe '/community/underdogs/forum/' do

# 	let(:user) { create :user, login: "user", password: "password" }
# 	let(:thread) { create :forum_thread }
# 	let(:forum) { create :forum }
# 	# let(:othread) { create :officer_thread }

# 	let(:csrf) { SecureRandom.hex(32) }

# 	let(:base_path) { "/community/underdogs/forum/" }

# 	let(:thread_attribs) do
# 		{
# 			title: "Foo",
# 			content: "Lorem Ipsum Bullshit Est",
# 			forum: forum
# 		}
# 	end

# 	let!(:previous_thread_count) { ForumThread.count }
# 	let(:new_thread_count) { ForumThread.count }

# 	before do
# 		instance_of(Application) do |a|
# 			stub(a).user { user }
# 		end
# 		stub(user).can?(:view_forum_threads) { true }
# 		stub(user).can? { false }
# 	end

# 	describe "creating a new thead" do
# 		context "without the required permission" do

# 			before do
# 				stub(user).can?(:create_forum_threads) { false }

# 				post "#{base_path}",
# 					{ thread: thread_attribs, potato: csrf },
# 					{ 'rack.session' => { csrf: [csrf] } }
# 			end

# 			it "returns 403" do
# 				expect(last_response).to be_forbidden
# 			end

# 			it "doesn't create a new thread" do
# 				expect(new_thread_count).to eq(previous_thread_count)
# 			end

# 			context "for officers" do

# 				before do
# 					stub(user).can?(:create_forum_threads) { true }
# 					stub(user).can?(:create_officer_threads) { false }

# 					post base_path,
# 						{ thread: thread_attribs.update(officer: true), potato: csrf },
# 						{ 'rack.session' => { csrf: [csrf] } }
# 				end

# 				it "returns 403" do
# 					expect(last_response).to be_forbidden
# 				end

# 				it "doesn't create a new thread" do
# 					expect(new_thread_count).to eq(previous_thread_count)
# 				end

# 			end
# 		end

# 		context "with the required permission" do

# 			before do
# 				mock(user).can?(:create_forum_threads) { true }
# 			end

# 			context "and valid data" do

# 				before do
# 					post base_path,
# 						{ thread: thread_attribs, potato: csrf },
# 						{ 'rack.session' => { csrf: [csrf] } }
# 				end

# 				it "doesn't return 403" do
# 					expect(last_response).to_not be_forbidden
# 				end

# 				it "redirects" do
# 					expect(last_response).to be_redirect
# 				end

# 				it "creates a new thread" do
# 					expect(new_thread_count).to eq(previous_thread_count + 1)
# 				end

# 			end

# 			context "but invalid data" do

# 				before do
# 					post base_path,
# 						{ thread: thread_attribs.update(content: nil), potato: csrf },
# 						{ 'rack.session' => { csrf: [csrf] } }
# 				end

# 				it "returns 200" do
# 					expect(last_response).to be_ok
# 				end

# 				it "doesn't create a new thread" do
# 					expect(new_thread_count).to eq(previous_thread_count)
# 				end

# 			end

# 		end

# 	end

# 	describe "adding a new post to a thread" do
# 	end

# 	describe "editing a post" do
# 	end

# 	describe "deleting a thread" do
# 	end

# 	describe "deleting a post" do
# 	end
# end
