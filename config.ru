# This file is used by Rack-based servers to start the application.

use Rack::Rewrite do
  rewrite %r{.*}, '/index.html', :if => Proc.new{|rack_env|
    puts"***SERVER NAME #{rack_env}"
    rack_env['SERVER_NAME'].start_with?('amala') && rack_env['HTTP_ACCEPT'] == 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
  }
end

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
