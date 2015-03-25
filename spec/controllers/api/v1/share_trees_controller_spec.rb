require 'rails_helper'

RSpec.configure do |c|
  c.include DonationStubber
end

describe Api::V1::ShareTreesController do
  before(:each) do
    @donation = create(:donation)
  end

  describe '#show' do
    context 'when donation is found' do
      it 'returns the share tree that corresponds with the donation' do
        stub_donation_finding @donation, @donation.id
        get :show, id: @donation.id
        expect(response).to have_http_status(:ok)
        expect(assigns[:donation]).to eq(@donation)
      end
    end
  end

end
