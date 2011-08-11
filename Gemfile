source :gemcutter

# This is our app.
# Bundler will append "lib" to the given path.
gem "application", "0.0", :path => "."

# Sinatra stuff
gem "sinatra", :require => "sinatra/base"
gem "sinatra-namespace", :require => "sinatra/namespace"
gem "sinatra-config-file", :require => "sinatra/config_file"
gem "rack-flash", :require => "rack/flash"
gem "rack-contrib", :require => "rack/contrib"
gem "sinatra-r18n", :require => 'sinatra/r18n'

# Tools
gem "logger"
gem "extlib"
gem "stringex"
gem "bcrypt-ruby"
gem "rdiscount"
#gem "redcarpet"
gem "unicorn"
#gem "pony"
gem "tmail"
gem "i18n"

# DB: Adapters included in groups below
gem "dm-core"
gem "dm-validations"
gem "dm-migrations"
gem "dm-types"

# Templating
gem "haml"
gem "compass"
gem "compass-susy-plugin"
gem 'coffee-filter'

group :development do
  gem "rake", :require => "rake/clean"
  gem "wirble"
  gem "dm-sqlite-adapter"
end

group :production do
  gem "dm-mysql-adapter"
end

group :test do
  gem "rspec"
  gem "rack-test", :require => "rack/test"
  gem "rr"
  gem "webrat"
  gem "database_cleaner"
end
