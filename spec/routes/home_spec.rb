describe "Home routes" do
	it "/" do
		get '/'
		expect(last_response.status).to eq(200)
	end
end
