require 'rails_helper'

RSpec.describe Organization, :type => :model do

  it { should have_many(:donations) }

  describe '#set_access_token' do
    it 'sets the access token based on the stripe api' do
      http_intercept
      organization = Organization.create(id: 1)
      organization.set_access_token 'ac_5eHQtezon3dqu1MCFbnOIJ6wBsLluOdY'
      expect(organization.reload.stripe_access_token).to be
    end
  end

  def http_intercept
    stub_request(:post, 'https://connect.stripe.com/oauth/token').
      to_return(body: {access_token: 'sk_test_SPNYvScKYYd4yI3J2IPZaRiE',
                          livemode: 'false',
                          refresh_token: 'rt_5duf0O9X8RdzBDnRfSfZapWcm7vrzd2c2WAKz9ombMq1wZ23',
                          token_type: 'bearer',
                          stripe_publishable_key: 'pk_test_sckgAK8fY9AekFVGcpBHvrPK',
                          stripe_user_id: 'acct_1038MV2UpLKQwkTh',
                          scope: 'read_only'
                      }.to_json)
  end
end
