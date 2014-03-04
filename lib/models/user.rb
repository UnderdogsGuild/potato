require 'bcrypt'
require 'digest/md5'

class User < Sequel::Model
	include BCrypt

	many_to_many :roles
	many_to_many :permissions
	one_to_many :news, class: :NewsEntry
	one_to_many :forum_posts, key: :author_id
	alias_method :posts, :forum_posts

	def gravatar_url
		@gravatar ||= "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(self.email.downcase)}?s=25"
	end

	##
	# Return URL of user's profile
	def url
		"/community/underdogs/members/#{login.downcase}"
	end

	##
	# Serialization methods for the xhr interface
	def as_json
		{
			login: self.login,
			email: self.email,
			gravatar_url: self.gravatar_url,
			last_login: self.last_login
		}
	end

	def to_json(*args)
		as_json.to_json
	end
	
	##
	# Easier template printing
	def to_s
		login
	end

	##
	# Return all threads started by user
	def threads
		@threads ||= posts.collect do |p|
			p.thread if p.is_thread_opener?
		end
	end

	##
	# Take care of password encoding and decoding
	def password
		Password.new( password_hash )
	end
	
	def password=(p)
		self.password_hash = Password.create(p)
	end

	##
	# Validate credentials
	def login?( pass )
		if password == pass then
			update last_login: Time.now
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

		@permissions << permissions.to_a

		@permissions.empty? ? [] : @permissions.flatten!.map!(&:to_s)
	end

	def _is_root?
		roles.each do |r|
			return true if r.is_root?
		end
		return false
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
