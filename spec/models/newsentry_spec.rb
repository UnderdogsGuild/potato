describe NewsEntry do
	##
	# Models are loaded before the migrations are run, so we need to refresh the
	# dataset to get our accessor methods.
	before :all do
		 NewsEntry.dataset = NewsEntry.dataset
	end

	it "creates the test entry successfully" do
		NewsEntry.create title: "Dat News Post", content: "Hell yeah!"
		NewsEntry.first.should_not be_nil
	end

	it "#published only returns published entries" do
		NewsEntry.create title: "Dat News Post", content: "Hell yeah!"
		NewsEntry.create title: "Dat News Post", content: "Hell yeah!"
		NewsEntry.create title: "Dat News Post", content: "Hell yeah!", published: false
		NewsEntry.create title: "Dat News Post", content: "Hell yeah!", published: false
		NewsEntry.all_published.to_a.length.should == 2
	end

	it "should populate the url field from the title field" do
		ne = NewsEntry.create title: "Dat News Post", content: "Hell yeah!"
		ne.url.should == ne.title.to_url
	end

	it "should update the url field when the title field changes" do
		ne = NewsEntry.create title: "Dat News Post", content: "Hell yeah!"
		ne.url.should == ne.title.to_url

		ne.title = "Doom is innevitable"
		ne.save
		ne.url.should == ne.title.to_url
	end
end
