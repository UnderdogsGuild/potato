class User
	include DataMapper::Resource
	include BCrypt

	has n, :groups, :through => Resource
	
	property :id, Serial
	property :login, String, :required => true
	property :password, String, :length => 60
	property :last_login, DateTime, :default => ->(a,b) { DateTime.now }

	##
	# Take care of password encoding and decoding
	def password
		Password.new( attribute_get(:password) )
	end
	
	def password= p
		attribute_set :password, Password.create( attribute_get(:password) )
	end

	##
	# Validate credentials
	def self.login? login, pass
		u = self.find_one({"login" => login})
		u.password == pass ? u : nil
	end

	def can? perm
		permissions.include? perm.to_sym
	end

	def permissions
		return @permissions if @permissions

		@permissions = []

		groups.all.each do |g|
			@permissions << g.permissions.all.to_a
		end

		@permissions.flatten!.map!(&:to_sym)

		@permissions
	end

end

class Group
	include DataMapper::Resource
	has n, :users, :through => Resource
	has n, :permissions

	property :id, Serial
	property :label, String
	property :description, String
	#property :permissions, Array
end

class Permission
	include DataMapper::Resource
	belongs_to :group

	property :id, Serial
	property :label, String
	property :description, String
end
