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
	def login?( pass )
		if self.password == pass then
			self.last_login = Time.now
			self
		end
	end

	def can?( perm )
		return true if self._is_root?
		_perms.include?(perm.to_s)
	end

	def _perms
		return @permissions if @permissions

		@permissions = []

		roles.each do |r|
			@permissions << r.permissions.to_a
		end

		@permissions.flatten!.map!(&:to_s)

		@permissions
	end

	def _is_root?
		roles.each do |r|
			 return true if r.is_root?
			 return false
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

	def to_s
		self[:label].to_s
	end
end
