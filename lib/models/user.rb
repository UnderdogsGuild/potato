class User < Sequel::Model
	include BCrypt

	many_to_many :roles
	many_to_many :permissions
	one_to_many :news, class: :NewsEntry

	##
	# Take care of password encoding and decoding
	def password
		Password.new( self[:password] )
	end
	
	def password= p
		self[:password] = Password.create( self[:password] )
	end

	##
	# Validate credentials
	def self.login? login, pass
		u = self.find(login: login)
		u.password == pass ? u : nil
	end

	def can? perm
		permissions.include? perm.to_sym
	end

	def permissions
		return @permissions if @permissions

		@permissions = []

		roles.all.each do |g|
			@permissions << g.permissions.all.to_a
		end

		@permissions.flatten!.map!(&:to_sym)

		@permissions
	end
end

class Role < Sequel::Model
	many_to_many :users
	many_to_many :permissions
end

class Permission < Sequel::Model
	many_to_many :users
	many_to_many :roles
end
