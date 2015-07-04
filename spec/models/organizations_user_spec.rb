require 'rails_helper'

RSpec.configure do |c|
  c.include StripeHelpers
end

RSpec.describe OrganizationsUser, :type => :model do

  it { should belong_to(:organization) }
  it { should belong_to(:user) }

  describe '#find_or_create' do
    context 'OrganizationsUser for user_id and organization_id already exists' do
      it 'returns that OrganizationsUser' do
        organizations_user = create(:organizations_user)
        result = OrganizationsUser.find_or_create(organizations_user.organization_id, organizations_user.user_id)

        expect(result).to eq(organizations_user)
      end
    end
    context 'keys do not exist' do
      it 'creates a new record' do
        user = create(:user)
        organization = create(:organization)
        result = OrganizationsUser.find_or_create(organization.id, user.id)
        expect(result.organization).to eq(organization)
        expect(result.user).to eq(user)
      end
    end
  end

  describe '#create_stripe_user' do
    it 'creates a user for the organization' do
      user = create(:stripe_user)
      organizations_user = create(:organizations_user)
      organizations_user.update_attribute('user_id', user.id)
      allow(organizations_user)
        .to receive(:create_stripe_token)
        .and_return(create_token)
      VCR.use_cassette('create_stripe_organization_user') do
        expect{organizations_user.create_stripe_user}
          .not_to raise_error
      end
    end
  end

  describe '#get_stripe_user' do
    context 'model does not have a stripe id' do
      it 'creates the stripe user' do
        organizations_user = create(:organizations_user)
        allow(organizations_user)
          .to receive(:create_stripe_user)
          .and_return(create_token_object) #fix this. Should return a user. instead returns a token.
        expect(organizations_user.get_stripe_user).to be
        expect(organizations_user)
          .to have_received(:create_stripe_user)
      end
    end

    context 'model does have a stripe id' do
      it 'retrieves the stripe user' do
        user = create(:stripe_user)
        organizations_user = create(:organizations_user)
        organizations_user.update_attribute('user_id', user.id)

        VCR.use_cassette('create_stripe_organization_user_helper') do
          organizations_user.create_stripe_user
        end
        VCR.use_cassette('retrieve_stripe_user') do
          expect(organizations_user.get_stripe_user).to be
        end
      end
    end
  end

  describe '#create_stripe_token' do
    it 'creates a token' do
      user = create(:stripe_user)
      organizations_user = create(:organizations_user)
      VCR.use_cassette('create_stripe_token_for_organizations_user') do
        expect(organizations_user.create_stripe_token user.stripe_id).to be
      end
    end
  end
end
