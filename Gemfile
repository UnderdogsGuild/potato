source 'https://rubygems.org'

# This is our app.
# Bundler will append "lib" to the given path.
gem "application", "0.0", path: "."

# Sinatra stuff
gem "sinatra"
gem "sinatra-namespace"
gem "sinatra-config-file"
# gem "rack-flash"
gem "rack-contrib"
gem "sinatra-r18n"
# gem "sinatra-partial"
gem "encrypted_cookie"

# Tools
gem "stringex"
gem "bcrypt"
gem "rdiscount"
gem "unicorn"
# gem "tmail"
# gem "i18n"

# DB: Adapters included in groups below
gem "sequel"

# Templating
gem "haml"
gem "sass"

group :development do
	gem "rake"
	gem "pry"
	gem 'foreman'
	gem 'shotgun'
	gem 'thin'
	gem 'rb-inotify', '~> 0.9'
end

gem "mysql2"

group :test do
	gem "rspec"
	gem "rack-test"
	gem "rr"
	gem "capybara"
	gem "poltergeist"
	gem "factory_girl", "~> 4.0"
	gem "faker"
end
