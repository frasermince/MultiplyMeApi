require 'rails_helper'

describe Overrides::OmniauthCallbacksController do


  describe '#omniauth_success' do
    it 'retrieves token from stripe' do
      organization = spy('organization')
      allow(Organization).to receive(:find).and_return(organization)
      get :omniauth_success, omniauth_success_params
      expect(organization).to have_received(:set_access_token).with(omniauth_success_params[:code])

    end
  end

  def omniauth_success_params
      {
        state: 1,
        scope: "read_write",
        code: "ac_5eHQtezon3dqu1MCFbnOIJ6wBsLluOdY",
        provider: "stripe_connect"
      }
  end
end
