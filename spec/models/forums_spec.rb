describe "Forum model" do
	##
	# While I can use let() and before :each, I find that it slows down tests
	# a *lot* when tons of database entries are created and cleared all the time.
	#
	# Since test examples are always wrapped in a transaction that is rolled back
	# afterwards, creating all necessary entities upfront makes much more sense.
	before :all do
		@user = create :user

		@thread = create :forum_thread
		@officer_thread = create :officer_thread
		@deleted_thread = create :deleted_thread

		@post = create :forum_post, forum_thread: @thread
		@officer_post = create :forum_post, forum_thread: @officer_thread
		@deleted_post = create :deleted_post, forum_thread: @thread

		@tag = create :tag
	end
	
	## 
	# They need to be cleaned after this test section is done, though, so it
	# doesn't affect other sections
	after :all do
		# Deletes cascade, so this will clear threads and posts too.
		ForumThread.each { |f| f.destroy }
	end

	##
	# This will make the default to be false, and allow us to only mock/stub what
	# is relevant to each test case below.
	before :each do
		stub(@user).can? { false }
	end

	describe ForumThread do
		describe "::visible_for(user)" do
			it "returns officer threads for officer users" do
				mock(@user).can?(:view_forum_threads) { true }
				mock(@user).can?(:view_officer_threads) { true }
				expect(ForumThread.visible_for(@user)).to include(@officer_thread)
			end

			it "doesn't return officer threads for non-officer users" do
				mock(@user).can?(:view_forum_threads) { true }
				mock(@user).can?(:view_officer_threads) { false }
				expect(ForumThread.visible_for(@user)).to_not include(@officer_thread)
			end

			it "returns deleted threads for officer users" do
				mock(@user).can?(:view_forum_threads) { true }
				mock(@user).can?(:view_deleted_threads) { true }
				expect(ForumThread.visible_for(@user)).to include(@deleted_thread)
			end

			it "doesn't returns deleted threads for non-officer users" do
				mock(@user).can?(:view_forum_threads) { true }
				mock(@user).can?(:view_deleted_threads) { false }
				expect(ForumThread.visible_for(@user)).to_not include(@deleted_thread)
			end

			it "returns regular threads for officers" do
				mock(@user).can?(:view_forum_threads) { true }
				mock(@user).can?(:view_officer_threads) { true }
				expect(ForumThread.visible_for(@user)).to include(@thread)
			end

			it "returns regular threads for non-officers" do
				mock(@user).can?(:view_forum_threads) { true }
				mock(@user).can?(:view_officer_threads) { false }
				expect(ForumThread.visible_for(@user)).to include(@thread)
			end
		end

		describe "posts_visible_for(user)" do
			it "returns regular posts for non-officers" do
				mock(@user).can?(:view_deleted_posts) { false }
				expect(@thread.posts_visible_for(@user)).to include(@post)
			end
			
			it "returns regular posts for officers" do
				mock(@user).can?(:view_deleted_posts) { true }
				expect(@thread.posts_visible_for(@user)).to include(@post)
			end

			it "doesn't return deleted posts for non-officers" do
				mock(@user).can?(:view_deleted_posts) { false }
				expect(@thread.posts_visible_for(@user)).to_not include(@deleted_post)
			end

			it "returns deleted posts for officers" do
				mock(@user).can?(:view_deleted_posts) { true }
				expect(@thread.posts_visible_for(@user)).to include(@deleted_post)
			end
		end

		describe "#add_post" do
			it "adds the post correctly" do
				@new_post = @thread.add_post(user: @user, content: "foo")

				expect(@thread.posts).to include(@new_post)
			end

			it "updates the timestamp on the thread" do
				Timecop.travel 30 do
					p = @thread.add_post user: @user, content: "foo"
					expect(@thread.updated_at).to eq(p.updated_at)
				end
			end
		end

		describe "#posts" do
			it "includes all child posts" do
				expect(@thread.posts).to include(@post)
			end
		end

		describe "#url" do
			it "contains the thread id" do
				expect(@thread.url).to include(@thread.id.to_s)
			end

			it "contains the thread slug" do
				expect(@thread.url).to include(@thread.slug)
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

		describe "thread tagging" do
			describe "#add_tag_by_name" do
				it "takes a tag name" do
					@thread.add_tag_by_name("event")
				end

				it "doesn't create new tags" do
					expect{@thread.add_tag_by_name("event")}.to_not change{Tag.all.count}
				end

				it "returns nil when attempting to add a non-existing tag" do
					expect(@thread.add_tag_by_name("Idontexist")).to be_nil
				end

				it "adds existing tags to threads" do
					expect(@thread.add_tag_by_name(@tag.name)).to_not be_nil
					expect(@thread.tags).to include(@tag)
				end
			end

			describe "#remove_tag_by_name" do
				it "removes a tag when given its name" do
					@thread.add_tag_by_name @tag.name
					expect(@thread.tags).to include(@tag)

					@thread.remove_tag_by_name @tag.name
					expect(@thread.tags).to_not include(@tag)
				end

				it "returns nil when attempting to remove a tag that's not associated with the thread" do
					expect(@thread.remove_tag_by_name(@tag.name)).to be_nil
				end
			end

			describe "::by_tag_names(*tns)" do
				before :each do
					@thread.add_tag_by_name @tag.name
				end

				it "finds a thread when given a tag name" do
					expect( ForumThread.by_tag_names(@tag.name) ).to include(@thread)
				end

				it "finds a thread when given multiple tag names" do
					@tag2 = create :tag
					@thread.add_tag_by_name @tag2.name
					expect( ForumThread.by_tag_names(@tag.name, @tag2.name) ).to include(@thread)
				end

				it "doesn't find threads not tagged with the given tag name" do
					@tag2 = create :tag
					expect( ForumThread.by_tag_names(@tag2.name) ).to_not include(@thread)
				end

				it "returns [] when searching for a nonexistent tag" do
					expect( ForumThread.by_tag_names("Idonotexist") ).to eq([])
				end
			end
		end

		describe "read tracking" do
			describe "#visit(user)" do
				it "updates an existing visit" do
					@visit = @thread.add_visit user: @user
					Timecop. travel 30 do
						@thread.visit @user
						expect { @visit.reload }.to change { @visit.when }
					end
				end

				it "creates a new visit when one doesn't exist" do
					mock(@thread.add_visit(user: @user)) { nil }
					@thread.visit(@user)
				end
			end

			describe "#first_new_post_for(user)" do
				it "returns the first post if there has been no visit" do
					expect(@thread.first_new_post_for(@user)).to eq(@thread.post)
				end

				it "returns the first new post since the last visit" do
					@thread.visit(@user)
					Timecop. travel 30 do
						p = @thread.add_post user: create(:user), content: "Foo"
						expect(@thread.first_new_post_for(@user)).to eq(p)
					end
				end

				it "returns the last post in a thread with no new posts" do
					p = @thread.add_post user: create(:user), content: "Foo"
					@thread.visit(@user)
					expect(@thread.first_new_post_for(@user)).to eq(p)
				end
			end
			
			describe "#updated_for?(user)" do
				it "returns true if there are new posts" do
					@thread.visit(@user)
					Timecop.travel 30 do
						@thread.add_post user: create(:user), content: "foo"
						expect(@thread.updated_for?(@user)).to be_truthy
					end
				end

				it "returns false if there are no new posts" do
					@thread.add_post user: create(:user), content: "foo"
					Timecop.travel 30 do
						@thread.visit(@user)
						expect(@thread.updated_for?(@user)).to be_falsey
					end
				end

				it "returns false if thread was bumped 30+ days ago" do
					Timecop.travel(Date.today + 32) do
						expect(@thread.updated_for?(@user)).to be_falsey
					end
				end
			end

			describe "::updated_for(user)" do
				describe "with an existing Visit" do
					it "doesn't return threads without new content" do
						@thread.add_post user: create(:user), content: "foo"
						Timecop.travel 30 do
							@thread.visit(@user)
							expect(ForumThread.updated_for(@user)).to_not include(@thread)
						end
					end

					it "returns threads with new content since the visit" do
						@thread.visit(@user)
						Timecop.travel 30 do
							@thread.add_post user: create(:user), content: "foo"
							expect(ForumThread.updated_for(@user)).to include(@thread)
						end
					end
				end

				describe "with no existing Visit" do
					before :each do
						Visit.where(user: @user, forum_thread: @thread).destroy
					end

					it "returns threads with new content" do
						@thread.add_post user: create(:user), content: "foo"
						expect(ForumThread.updated_for(@user)).to include(@thread)
					end

					it "doesn't return threads updated longer than 30 days ago" do
						Timecop.travel(Date.today + 32) do
							expect(ForumThread.updated_for(@user)).to_not include(@thread)
						end
					end
				end
			end
		end

		describe "thread starring" do
			describe "#star_for(user)" do
				it "adds a star" do
					@thread.star_for(@user)
					expect( @thread.stars_dataset.first(user: @user) ).to_not be_nil
				end

				it "doesn't add duplicate stars" do
					@thread.star_for(@user)
					@thread.star_for(@user)
					expect( @thread.stars_dataset.where(user: @user).count ).to eq(1)
				end
			end

			describe "#starred_for?(user)" do
				it "returns true if a thread is starred for a user" do
					@thread.star_for(@user)
					expect( @thread.starred_for?(@user) ).to be_truthy
				end

				it "returns false if a thread is not starred for a user" do
					expect( @thread.starred_for?(@user) ).to be_falsey
				end
			end

			describe "::starred_for(user)" do
				it "returns threads starred for a user" do
					@thread.star_for(@user)
					expect( ForumThread.starred_for(@user) ).to include(@thread)
				end

				it "doestn't returns threads not starred for a user" do
					expect( ForumThread.starred_for(@user) ).to_not include(@thread)
				end
			end
		end

		describe "searching" do
			# describe "query string parsing" do
			# 	it "delegates tag search to ::by_tag_names()" do
			# 		mock(ForumThread).by_tag_names(@tag.name) { [] }
			# 		ForumThread.search("@#{@tag.name}", @user)
			# 	end

			# 	it "finds tagged threads" do
			# 		@thread.add_tag_by_name(@tag.name)
			# 		expect( ForumThread.search("@#{@tag.name}", @user) ).to include(@thread)
			# 	end
			# end

			# describe "fulltext searching" do
			# 	it "delegates text queries to the fulltext search" do
			# 		expect( ForumThread.search(@thread.post.content.split[1], @user) ).to include(@thread)
			# 	end
			# end

			describe "state searching" do
				before :each do
					@starred_thread = create :forum_thread
					@starred_thread.star_for(@user)

					@unread_thread = create :forum_thread
				end

				# it "returns starred threads with %starred" do
				# 	expect( ForumThread.search("%starred", @user) ).to include(@starred_thread)
				# end
				
				# it "returns unread threads with %unread" do
				# 	expect( ForumThread.search("%unread", @user) ).to include(@unread_thread)
				# end
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

		describe "timestamps" do
			it "updates the updated_at field automatically" do
				Timecop.travel 30 do
					expect{@post.update(content: "bar")}.to change { @post.updated_at }
				end
			end
		end

		# describe "#create" do
		# 	it "updates the parent thread's timestamp" do
		# 		#Timecop.travel(Date.today + 2)
		# 		expect { create :forum_post, forum_thread: @thread }
		# 			.to change { @thread.updated_at }
		# 	end
		# end

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
