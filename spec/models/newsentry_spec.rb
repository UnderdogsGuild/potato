describe NewsEntry do
	##
	# Models are loaded before the migrations are run, so we need to refresh the
	# dataset to get our accessor methods.
	before :all do
		 NewsEntry.dataset = NewsEntry.dataset
	end

	it "creates the test entry successfully" do
		NewsEntry.create title: "Dat News Post", content: "Hell yeah!"
		expect(NewsEntry.first).to_not be_nil
	end

	it "#published only returns published entries" do
		NewsEntry.create title: "Dat News Post", content: "Hell yeah!"
		NewsEntry.create title: "Dat News Post", content: "Hell yeah!"
		NewsEntry.create title: "Dat News Post", content: "Hell yeah!", published: false
		NewsEntry.create title: "Dat News Post", content: "Hell yeah!", published: false
		expect(NewsEntry.all_published.to_a.length).to eq(2)
	end

	it "should populate the url field from the title field" do
		ne = NewsEntry.create title: "Dat News Post", content: "Hell yeah!"
		expect(ne.url).to eq(ne.title.to_url)
	end

	it "should update the url field when the title field changes" do
		ne = NewsEntry.create title: "Dat News Post", content: "Hell yeah!"
		expect(ne.url).to eq(ne.title.to_url)

		ne.title = "Doom is innevitable"
		ne.save
		expect(ne.url).to eq(ne.title.to_url)
	end
end
