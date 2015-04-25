module Overrides
  class OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
    skip_before_action :authenticate_user!
    def omniauth_success
      if params[:provider] == 'stripe_connect'
        organization = Organization.find params[:state]
        organization.set_access_token(params[:code])
      else
        super
      end
      Rails.logger.warn "***HERE"
    end

    def resource_class
      User
    end
  end
end
