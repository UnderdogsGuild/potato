describe "Forum" do
	##
	# Models are loaded before the migrations are run, so we need to refresh the
	# dataset to get our accessor methods.
	before :all do
		 ForumThread.dataset = ForumThread.dataset
		 ForumPost.dataset = ForumPost.dataset
	end

	before :each do
		@thread = ForumThread.create title: "This thread is dope, yo!"
		ForumPost.create author: User.first, forum_thread: @thread, content: "First!! haha"
	end

	it "works" do
		expect(ForumThread.first).to_not be_nil
		expect(ForumThread.first.forum_posts.first).to_not be_nil
	end
end
