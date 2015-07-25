require 'rails_helper'

RSpec.describe 'Challenged pledges API', type: :request do
  before { host! "api.multiplyme.in" }
  it 'returns challenged pledges for the donation' do
    donation = create(:donation)
    other_organization = create(:organization)
    other_organization_donation = create(:donation)
    other_organization_donation.update_attribute('organization_id', other_organization.id)
    get '/v1/challenged_pledges', organization_id: donation.organization_id
    expect(json['donations'].count).to be
  end
end
