require 'digest/sha2'
require 'securerandom'

describe "Auth routes" do
	before :all do
		@password = Digest::SHA2.new(512).update("mah passwerd").to_s
		@csrf_token = SecureRandom.hex(32)
		@user = create :user, password: @password

		unless @user.can? :log_in
			@plogin = create :permission, label: "log_in"
			@rmember = create :role, label: "member"
			@rmember.add_permission @plogin unless @rmember.permissions.include? @plogin
			@user.add_role @rmember unless @user.roles.include? @rmember
		end
	end

	describe "csrf tokens" do
		it "should be inserted in the login form" do
			get '/login'

			expect(last_response).to be_ok
			expect(last_response).to match(/input type='hidden' name='potato'/)
		end

		it "should be required" do
			get '/login'
			post '/login',
				{ username: @user.login, password: @password, action: "login", remember: true }

			expect(last_response).to be_forbidden
			expect(last_request.env['rack.session'][:user]).to be_nil
		end

		it "should be accepted" do
			get '/login'
			post '/login',
				{ username: @user.login, password: @password, action: "login", remember: true, potato: @csrf_token },
				{ 'rack.session' => { csrf: [@csrf_token] } }

			follow_redirect!
			expect(last_request.env['rack.session'][:user]).to_not be_nil
		end
	end
end
