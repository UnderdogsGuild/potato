describe "Forum" do
	before :each do
		@thread = create(:forum_thread)
		@othread = create(:officer_thread)
	end

	it "ForumPost#is_thread_opener?" do
		expect(@thread.forum_posts.first.is_thread_opener?).to be_true
		expect(@thread.forum_posts.last.is_thread_opener?).to be_false
	end
end
