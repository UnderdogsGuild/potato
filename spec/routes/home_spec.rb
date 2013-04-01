describe "Home routes" do
	before :all do
		@news_entry = NewsEntry.create title: "Test entries are cool", tagline: "They really are",
			content: "Oh so fucking cool", published: true

		@page = Page.create title: "Pagey pagey on the wall", content: "Who's the prettiest coder of all"
	end

	['/', '/news', '/news/'].each do |r|
		it "#{r}" do
			get r
			last_response.status.should == 200
			last_response.body.should have_selector("article#entry-#{@news_entry.id}")
		end
	end

	it "/news/:slug" do
		get "/news/#{NewsEntry.first.slug}"
		last_response.status.should == 200
		last_response.body.should contain("Test entries are cool")
	end

	it "/:page" do
		get "/#{Page.first.url}"
		last_response.status.should == 200
		last_response.body.should contain("the prettiest coder of all")
	end
end
