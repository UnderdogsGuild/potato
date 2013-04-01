require 'bundler/setup'
Bundler.require

#use Rack::Profiler if ENV['RACK_ENV'] == 'development'

#use Rack::ETag
#use Rack::MailExceptions do |c|
  ## Use local sendmail
  #c.from  "Rack Exceptions"
  #c.to    "me@mkaito.com"
#end

use Rack::BounceFavicon
#use Rack::Backstage, 'public/maintenance.html'
use Rack::Deflect

run ::Application
