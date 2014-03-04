describe "Forum" do
	before :each do
		@thread = create(:forum_thread)
		@othread = create(:officer_thread)
	end

	describe ForumThread do
		before :each do
			@user = build(:user)
			@officer = build(:user)
		end

		it "Shows officer threads to officers" do
			mock(@officer).can?(:view_forum_threads) { true }
			mock(@officer).can?(:view_officer_threads) { true }
			expect(ForumThread.visible_for(@officer)).to include(@othread)
		end

		it "Hides officer threads from non-officers" do
			mock(@user).can?(:view_forum_threads) { true }
			mock(@user).can?(:view_officer_threads) { false }
			expect(ForumThread.visible_for(@user)).to_not include(@othread)
		end
	end

	describe ForumPost do
		it "#is_thread_opener?" do
			expect(@thread.forum_posts.first.is_thread_opener?).to be_true
			expect(@thread.forum_posts.last.is_thread_opener?).to be_false
		end
	end
end
