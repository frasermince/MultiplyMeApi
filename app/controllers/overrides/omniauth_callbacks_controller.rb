require 'rest_client'
module Overrides
  class OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
    skip_before_action :authenticate_user!
    def omniauth_success
      if params[:provider] == 'stripe_connect'
        retrieve_oauth_token
      end
    end

    private
    def retrieve_oauth_token
      response = RestClient.post('https://connect.stripe.com/oauth/token', oauth_params)
      handle_response response.headers, params[:state]
    end

    def oauth_params
      {
        client_secret: Rails.application.secrets.stripe_secret_key,
        code: params[:code],
        grant_type: 'authorization_code',
        accept: :json,
        content_type: :json
      }
    end

    def handle_response(response, organization_id)
      organization = Organization.find organization_id
      organization.stripe_access_token = response[:access_token]
      organization.save
    end

  end
end
