describe "Home routes" do
	it "/" do
		get '/'
		last_response.status.should == 200
	end
end
