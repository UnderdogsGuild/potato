describe "Forum models" do
	before :all do
		@user = create :user

		@forum = create :forum
		@officer_forum = create :officer_forum

		@thread = create :forum_thread, forum: @forum
		@officer_thread = create :forum_thread, forum: @officer_forum

		@post = create :forum_post, forum_thread: @thread
		@officer_post = create :forum_post, forum_thread: @officer_thread
	end
	
	after :all do
		# Deletes cascade, so this will clear threads and posts too.
		Forum.each { |f| f.destroy }
	end

	describe Forum do
		it "validates the presence of a forum name" do
			forum = Forum.new name: nil, description: "something"
			expect(forum).to_not be_valid
		end

		it "validates the presence of a description" do
			forum = Forum.new name: "something", description: nil
			expect(forum).to_not be_valid
		end

		it "is valid when both name and description are set" do
			forum = Forum.new name: "something", description: "something"
			expect(forum).to be_valid
		end

		describe "::visible_for(user)" do
			it "returns officer forums for officer users" do
				mock(@user).can?(:view_forum_threads) { true }
				mock(@user).can?(:view_officer_forums) { true }
				expect(Forum.visible_for(@user)).to include(@officer_forum)
			end

			it "doesn't return officer forums for non-officer users" do
				mock(@user).can?(:view_forum_threads) { true }
				mock(@user).can?(:view_officer_forums) { false }
				expect(Forum.visible_for(@user)).to_not include(@officer_forum)
			end

			it "returns regular forums for officers" do
				mock(@user).can?(:view_forum_threads) { true }
				mock(@user).can?(:view_officer_forums) { true }
				expect(Forum.visible_for(@user)).to include(@forum)
			end

			it "returns regular forums for non-officers" do
				mock(@user).can?(:view_forum_threads) { true }
				mock(@user).can?(:view_officer_forums) { false }
				expect(Forum.visible_for(@user)).to include(@forum)
			end
		end

		describe "#threads" do
			it "finds all child threads" do
				expect(@forum.threads.count).to eq(2)
			end
			
			it "includes all child threads" do
				expect(@forum.threads).to include(@thread)
			end
		end

		describe "#url" do
			it "should return a string" do
				expect(@forum.url).to be_kind_of(String)
			end

			it "returns a string containing the forum name" do
				expect(@forum.url).to include(@forum.name.to_url)
			end
		end
	end

	describe ForumThread do
		describe "#forum" do
			it "finds the parent forum" do
				expect(@thread.forum).to be(@forum)
			end
		end

		describe "#posts" do
			it "finds all child posts" do
				expect(@thread.posts.count).to eq(2)
			end
			
			it "includes all child posts" do
				expect(@thread.posts).to include(@post)
			end
		end

		describe "#url" do
			it "contains the thread id" do
				expect(@thread.url).to include(@thread.id.to_s)
			end
		end

		describe "#post" do
			it "returns the first post in the thread" do
				expect(@thread.post).to be(@thread.posts.first)
			end
		end

		describe "#author" do
			it "delegates to the first post" do
				expect(@thread.author).to be(@thread.post.user)
			end
		end

		describe "#content" do
			it "delegates to the first post" do
				expect(@thread.content).to be(@thread.post.content)
			end
		end
	end

	describe ForumPost do
		describe "validation" do
			it "requires content" do
				@post.content = nil
				expect(@post).to_not be_valid
			end
		end

		describe "#user" do
			it "finds the author" do
				expect(@post.user).to be_kind_of(User)
			end

			it "is aliased as #author" do
				expect(@post.author).to be(@post.user)
			end
		end

		describe "#thread" do
			it "finds the parent thread" do
				expect(@post.thread).to be(@thread)
			end
		end

		describe "#is_thread_opener?" do
			it "returns true when called on the first post of a thread" do
				expect(@thread.posts[0].is_thread_opener?).to be_truthy
			end

			it "returns false when called on a post that's not the first in a thread" do
				expect(@thread.posts[1].is_thread_opener?).to be_falsey
			end
		end

		describe "#url" do
			it "ends with an anchor to the post" do
				expect(@post.url).to match(/##{@post.html_id}$/)
			end
		end

		describe "#html_id" do
			it "builds a correct id string" do
				expect(@post.html_id).to eq("post-#{@post.id}")
			end
		end
	end
end
