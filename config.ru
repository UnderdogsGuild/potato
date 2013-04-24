require 'bundler/setup'
require 'application'


use Rack::ETag
use Rack::BounceFavicon
#use Rack::Backstage, 'public/maintenance.html'
use Rack::Deflect

run ::Application
