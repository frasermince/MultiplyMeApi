require 'rails_helper'

RSpec.configure do |c|
  c.include Stubber
end

describe Api::V1::OrganizationsController do
  describe '#show' do
    context 'when organization is found' do
      it 'returns the orgaziation and sets the status to ok' do
        organization = create(:organization)
        stub_finding organization, organization.id
        get :show, id: organization.id
        expect(response).to have_http_status(:ok)
        expect(assigns[:organization]).to eq(organization)
      end
    end

    context 'when donation is not found' do
      it 'returns the error and sets the status to not found' do
        get :show, id: 2
        expect(response).to have_http_status(:not_found)
      end
    end
  end

end
