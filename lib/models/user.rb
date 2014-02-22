class User < Sequel::Model
	include BCrypt

	many_to_many :roles
	many_to_many :permissions
	one_to_many :news, class: :NewsEntry

	##
	# Take care of password encoding and decoding
	def password
		Password.new( self.password_hash )
	end
	
	def password=(p)
		self.password_hash = Password.create( p )
	end

	##
	# Validate credentials
	def self.login?( login, pass )
		u = self.find( login: login )
		if u && u.password == pass then
			u.last_login = Time.now
			return u
		end
	end

	def can?( perm )
		return true if self._is_root?
		_perms.include? perm.to_sym
	end

	def _perms
		return @permissions if @permissions

		@permissions = []

		roles.each do |r|
			@permissions << r.permissions.to_a
		end

		@permissions.flatten!.map!(&:to_sym)

		@permissions
	end

	def _is_root?
		roles.each do |r|
			 return true if r.is_root?
			 false
		end
	end
end

class Role < Sequel::Model
	many_to_many :users
	many_to_many :permissions

	def is_root?
		self[:root]
	end
end

class Permission < Sequel::Model
	many_to_many :users
	many_to_many :roles

	def to_sym
		self[:label].to_sym
	end
end
