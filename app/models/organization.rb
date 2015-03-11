require 'rest_client'
# Stores information related to a specific nonprofit
# This includes authorization key to organization's stripe account
class Organization < ActiveRecord::Base
  has_many :donations

  def set_access_token(code)
      response = RestClient.post('https://connect.stripe.com/oauth/token', oauth_params(code))
      handle_response response
  end

  private
  def oauth_params(code)
    {
      client_secret: Rails.application.secrets.stripe_secret_key,
      code: code,
      grant_type: 'authorization_code',
      accept: :json,
      content_type: :json
    }
  end

  def handle_response(response)
    response = JSON.parse(response)
    self.stripe_access_token = response['access_token']
    self.save
  end
end
