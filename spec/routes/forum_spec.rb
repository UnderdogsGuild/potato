describe '/community/underdogs/forum/' do

  let(:base) { "/community/underdogs/forum/" }

  let(:thread_attribs) do
    {
      title: "Foo",
      content: "Lorem Ipsum Bullshit Est"
    }
  end

  before :all do
    @user = create :user, login: "user", password: "password"
    create_list :forum_thread, 2, post_count: 2, officer: false
    create_list :officer_thread, 2, post_count: 2

		@csrf = SecureRandom.hex(32)
  end

  after :all do
    ForumThread.each { |t| t.remove_all_forum_posts; t.destroy }
    User.each { |u| u.remove_all_forum_posts; u.destroy}
    ForumPost.each { |p| p.destroy }
  end

  before :each do
    any_instance_of(Application) do |a|
      stub(a).user { @user }
    end
    stub(@user).can? { false }
    stub(@user).can?(:view_forum_threads) { true }
    stub(@user).can?(:log_in) { true }
  end

  context "creating a new thead" do
    context "without the required permission" do

      before :each do
        @count = ForumThread.count
        stub(@user).can?(:create_forum_threads) { false }
      end

      it "fails" do
        post "#{base}",
          { thread: thread_attribs, potato: @csrf },
          { 'rack.session' => { csrf: [@csrf] } }

        expect(last_response).to be_forbidden
        expect(ForumThread.count).to eq(@count)
      end

      context "for officers" do
        it "fails" do
          @count = ForumThread.count
          stub(@user).can?(:create_forum_threads) { true }
          stub(@user).can?(:create_officer_threads) { false }

          post "#{base}",
            { thread: thread_attribs.update(officer: true), potato: @csrf },
            { 'rack.session' => { csrf: [@csrf] } }

          expect(last_response).to be_forbidden
          expect(ForumThread.count).to eq(@count)
        end
      end

    end

    context "with the required permission" do

      before :each do
        @count = ForumThread.count
        mock(@user).can?(:create_forum_threads) { true }
      end

      it "succeeds" do
        post "#{base}",
          { thread: thread_attribs, potato: @csrf },
          { 'rack.session' => { csrf: [@csrf] } }

        expect(last_response).to_not be_forbidden
        expect(last_response).to be_redirect
        expect(ForumThread.count).to eq((@count + 1))
      end

      context "with invalid thread data" do

        it "fails" do
          post "#{base}",
            { thread: thread_attribs.update(title: nil), potato: @csrf },
            { 'rack.session' => { csrf: [@csrf] } }

          expect(last_response).to be_ok
          expect(ForumThread.count).to eq(@count)
        end

      end

    end
  end

  context "replying to a thread" do
  end

  context "editing an existing thread" do
  end

  context "editing a single post" do
  end

  context "deleting a thread" do
  end

  context "deleting a single post" do
  end
end
