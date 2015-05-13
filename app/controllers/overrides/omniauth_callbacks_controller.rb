module Overrides
  class OmniauthCallbacksController < DeviseTokenAuth::OmniauthCallbacksController
    skip_before_action :authenticate_user!

    def redirect_callbacks
      # derive target redirect route from 'resource_class' param, which was set
      # before authentication.
      devise_mapping = session['omniauth.params']['resource_class'].underscore.to_sym
      redirect_route = "#{Devise.mappings[devise_mapping].as_json["path"]}/#{params[:provider]}/callback"

      # preserve omniauth info for success route. ignore 'extra' in twitter
      # auth response to avoid CookieOverflow.
      #session['dta.omniauth.auth'] = request.env['omniauth.auth'].except('extra')
      session['dta.omniauth.params'] = session['omniauth.params']

      redirect_to redirect_route
    end

    def omniauth_success
      if params[:provider] == 'stripe_connect'
        organization = Organization.find params[:state]
        organization.set_access_token(params[:code])
      else
        super
      end
    end

    def resource_class
      User
    end
  end
end
