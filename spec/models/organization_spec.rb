require 'rails_helper'

RSpec.configure do |c|
  c.include StripeHelpers
end

RSpec.describe Organization, :type => :model do

  it { should have_many(:donations) }
  it { should have_many(:users).through(:organizations_user) }

  describe '#get_stripe_user' do
    it 'fetches the stripe user' do
      organization = create(:organization)
      user = create(:stripe_user)
      organizations_user = create(:organizations_user)
      allow(OrganizationsUser).to receive(:find_or_create).and_return(organizations_user)
      allow_any_instance_of(Organization)
        .to receive(:create_stripe_user)
        .and_return(create_token_object) #fix this. Should return a user. instead returns a token.
      expect(organization.get_stripe_user(user)).to be
    end
  end

  describe '#create_stripe_user' do
    it 'creates a user for the organization' do
      user = create(:stripe_user)
      organization = create(:organization)
      allow_any_instance_of(Organization)
        .to receive(:create_stripe_token)
        .and_return(create_token)
      VCR.use_cassette('create_stripe_organization_user') do
        expect{organization.create_stripe_user user.stripe_id, user.email}.not_to raise_error
      end
    end
  end

  describe '#get_stripe_token' do
    it 'creates a token' do
      user = create(:stripe_user)
      organization = create(:organization)
      VCR.use_cassette('create_stripe_token_for_organization') do
        expect(organization.create_stripe_token user.stripe_id).to be
      end
    end
  end

  describe '#set_access_token' do
    it 'sets the access token based on the stripe api' do
      http_intercept
      organization = Organization.create(id: 1)
      organization.set_access_token 'ac_5eHQtezon3dqu1MCFbnOIJ6wBsLluOdY'
      expect(organization.reload.stripe_access_token).to be
      expect(organization.reload.stripe_id).to be
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
