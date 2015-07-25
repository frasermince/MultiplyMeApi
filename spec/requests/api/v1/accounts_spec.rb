require 'rails_helper'

RSpec.describe 'Accounts API', type: :request do
  before { host! "api.multiplyme.in" }
  context 'donation on user has children' do
    it 'calculates the network impact based upon children' do
      setup
      child_donation = create(:donation)
      child_donation.update_attribute('is_paid', true)
      child_donation.update_attribute('parent_id', @donation.id)
      child_donation.update_attribute('user_id', create(:user).id)
      @donation.children.push child_donation
      get "/v1/accounts/#{@user.id}", organization_id: @donation.organization_id
      expect(json['network_impact']).to eq(child_donation.yearly_amount)
    end
  end
  context 'no organization is given' do
    it 'returns impacts and amounts for all donations' do
      setup
      get "/v1/accounts/#{@user.id}", organization_id: @donation.organization_id
      expect(json['personal_impact']).to eq(@donation.yearly_amount)
    end
  end

  context 'organization having donations is passed to request' do
    it 'returns impacts and amounts for donations on that organization' do
      setup
      get "/v1/accounts/#{@user.id}", organization_id: @donation.organization_id
      expect(json['personal_impact']).to eq(@donation.yearly_amount)
    end
  end

  context ' organization without donations is passed to request' do
    it 'gives amounts of zero' do
      setup
      get "/v1/accounts/#{@user.id}", organization_id: @donation.organization_id + 1
      expect(json['personal_impact']).to eq(0)
    end
  end

  def setup
    @user = create(:user)
    @donation = create(:donation)
    @donation.update_attribute('is_paid', true)
  end

end
