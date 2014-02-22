feature "Home routes" do
	scenario "/" do
		visit '/'
		#expect(last_response.status).to eq(200)
	end
end
