# This file is used by Rack-based servers to start the application.
require 'rack/rewrite'
require 'rack/cors'
use Rack::Cors do
  allow do
    origins 'localhost:9001', 'amala.multiplyme.in', ' amala-multiplyme.in.s3-website-us-west-2.amazonaws.com/'
    resource '*',
      :methods => [:get, :post, :put, :delete, :options],
      :headers => :any,
      :expose  => ['access-token', 'token-type', 'client', 'expiry', 'uid']
  end
end

use Rack::Rewrite do

  # if it does not start with amala and it is routing
  # to angular files redirect to 404
  rewrite %r{.*/ngApp/.*}, '/ngApp/404.html', not: lambda{|rack_env|
    rack_env['SERVER_NAME'].start_with?('amala')
  }

  # rewrites requests under the amala subdomain to angular
  # app in public/ngApp directory. If it is a html file it
  # will be redirected so that the angular routes will take over.
  # Otherwise it just adds ngApp to the beginning of the path
  rewrite %r{.*},
    lambda{|match, rack_env|
    url = '/ngApp'
    if rack_env['HTTP_ACCEPT'] == 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
      url += '/index.html'
    else
      url += rack_env['PATH_INFO']
    end
    url
  },
  :if => lambda{|rack_env|
    rack_env['SERVER_NAME'].start_with?('amala')
  }

end

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
