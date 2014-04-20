describe Post do
	let(:user) { User.create login: "foo", password: "bar" }
	let(:valid_post) { Post.new(title: "foo", content: "bar", author: user) }
	let(:post) { Post.new }

	it "works" do
		expect(post).to_not be_valid
	end

	it "validates" do
		expect(valid_post).to be_valid
	end
	# before :each do
	# 	@thread = create(:forum_thread)
	# 	@othread = create(:officer_thread)
	# end

	# describe ForumThread do
	# 	before :each do
	# 		@user = create(:user)
	# 		@officer = create(:user)
	# 	end

	# 	it "Shows officer threads to officers" do
	# 		stub(@officer).can?(:view_forum_threads) { true }
	# 		stub(@officer).can?(:view_officer_threads) { true }
	# 		expect(ForumThread.visible_for(@officer)).to include(@othread)
	# 	end

	# 	it "Hides officer threads from non-officers" do
	# 		stub(@user).can?(:view_forum_threads) { true }
	# 		stub(@user).can?(:view_officer_threads) { false }
	# 		expect(ForumThread.visible_for(@user)).to_not include(@othread)
	# 	end

	# 	it "can build a list of threads for a user" do
	# 		create_list(:forum_thread, 5, author: @user)
	# 		expect(@user.threads.count).to eq(5)
	# 	end
	# end

	# describe ForumPost do
	# 	it "#is_thread_opener?" do
	# 		expect(@thread.forum_posts.first.is_thread_opener?).to be_true
	# 		expect(@thread.forum_posts.last.is_thread_opener?).to be_false
	# 	end
	# end
end
