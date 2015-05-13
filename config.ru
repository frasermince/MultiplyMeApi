# This file is used by Rack-based servers to start the application.
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

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
