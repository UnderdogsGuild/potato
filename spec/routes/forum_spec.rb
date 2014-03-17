describe '/community/underdogs/forum/' do

	let(:user) { create :user, login: "user", password: "password" }
	let(:thread) { create :forum_thread }
	let(:othread) { create :officer_thread }

	let(:csrf) { SecureRandom.hex(32) }

	let(:base_path) { "/community/underdogs/forum/" }

	let(:thread_attribs) do
		{
			title: "Foo",
			content: "Lorem Ipsum Bullshit Est"
		}
	end

	let!(:previous_thread_count) { ForumThread.count }
	let(:new_thread_count) { ForumThread.count }

	before do
		any_instance_of(Application) { |a| stub(a).user { user } }
		stub(user).can? { false }
		stub(user).can?(:view_forum_threads) { true }
	end

	describe "creating a new thead" do
		context "without the required permission" do

			before do
				stub(user).can?(:create_forum_threads) { false }

				post "#{base_path}",
					{ thread: thread_attribs, potato: csrf },
					{ 'rack.session' => { csrf: [csrf] } }
			end

			it "returns 403" do
				expect(last_response).to be_forbidden
			end

			it "doesn't create a new thread" do
				expect(new_thread_count).to eq(previous_thread_count)
			end

			context "for officers" do

				before do
					stub(user).can?(:create_forum_threads) { true }
					stub(user).can?(:create_officer_threads) { false }

					post base_path,
						{ thread: thread_attribs.update(officer: true), potato: csrf },
						{ 'rack.session' => { csrf: [csrf] } }
				end

				it "returns 403" do
					expect(last_response).to be_forbidden
				end

				it "doesn't create a new thread" do
					expect(new_thread_count).to eq(previous_thread_count)
				end

			end
		end

		context "with the required permission" do

			before do
				mock(user).can?(:create_forum_threads) { true }
			end

			context "and valid data" do

				before do
					post base_path,
						{ thread: thread_attribs, potato: csrf },
						{ 'rack.session' => { csrf: [csrf] } }
				end

				it "doesn't return 403" do
					expect(last_response).to_not be_forbidden
				end

				it "redirects" do
					expect(last_response).to be_redirect
				end

				it "creates a new thread" do
					expect(new_thread_count).to eq(previous_thread_count + 1)
				end

			end

			context "but invalid data" do

				before do
					post base_path,
						{ thread: thread_attribs.update(content: nil), potato: csrf },
						{ 'rack.session' => { csrf: [csrf] } }
				end

				it "returns 200" do
					expect(last_response).to be_ok
				end

				it "doesn't create a new thread" do
					expect(new_thread_count).to eq(previous_thread_count)
				end

			end

		end

	end

	describe "adding a new post to a thread" do
	end

	describe "editing a post" do
	end

	describe "deleting a thread" do
	end

	describe "deleting a post" do
	end
end
