require 'rest_client'
module Overrides
  class OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
    skip_before_action :authenticate_user!
    def omniauth_success
      if params[:provider] == 'stripe_connect'
        RestClient.post('https://connect.stripe.com/oauth/token',
        {
          client_secret: Rails.application.secrets.stripe_secret_key,
          code: params[:code],
          grant_type: 'authorization_code'
        }){|response, request, result, &block|
          @response = response
        }
      end
    end
  end
end
