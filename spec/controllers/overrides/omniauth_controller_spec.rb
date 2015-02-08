require 'rails_helper'

describe Overrides::OmniauthCallbacksController do

  before(:each) do
    stub_request(:post, 'https://connect.stripe.com/oauth/token').
      to_return(headers: {access_token: 'sk_test_SPNYvScKYYd4yI3J2IPZaRiE',
                livemode: 'false',
                refresh_token: 'rt_5duf0O9X8RdzBDnRfSfZapWcm7vrzd2c2WAKz9ombMq1wZ23',
                token_type: 'bearer',
                stripe_publishable_key: 'pk_test_sckgAK8fY9AekFVGcpBHvrPK',
                stripe_user_id: 'acct_1038MV2UpLKQwkTh',
                scope: 'read_only'})
  end

  describe '#omniauth_success' do
    it 'retrieves token from stripe' do
      organization = Organization.create(id: 1)
      get :omniauth_success, omniauth_success_params
      expect(organization.reload.stripe_access_token).to be
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
