source 'https://code.stripe.com'
source 'https://rubygems.org'

gem "capistrano-resque", "~> 0.2.1", require: false
gem 'rails', '4.2.0'
gem 'responders', '~> 2.0'
gem 'omniauth-stripe-connect'
gem 'capistrano'
gem 'rest-client'
gem 'stripe', :source => 'https://code.stripe.com/'
gem 'sendgrid-ruby'
gem 'gravatar_image_tag'
gem 'omniauth-facebook', '2.0.1'
gem 'mono_logger'

gem 'unicorn'
gem 'rails-api'

gem 'spring', :group => :development

gem 'omniauth'
gem 'devise_token_auth', git: 'git@github.com:frasermince/devise_token_auth.git'
#gem 'devise_token_auth', '0.1.31'
gem 'pg'
gem 'rack-cors', :require => 'rack/cors'
gem 'mailchimp-api'
gem 'foreman'
gem 'foreman-export-initscript'
gem 'resque'
gem 'resque-scheduler', '2.5.4'
gem 'metric_fu'
gem 'vcr'

group :development do
  gem 'guard'
  gem 'guard-rspec', require: false
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'pry'
end

group :test do
  gem 'factory_girl_rails'
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
  gem 'webmock'
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano', :group => :development

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
