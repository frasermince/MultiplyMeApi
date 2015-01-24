require 'rails_helper'

describe Api::V1::DonationsController do
  describe '#create' do
    context 'when donation is valid' do
      it 'returns the donation and sets the status to created' do
        donation = Donation.create(amount: 5)
        stub_donation_creation donation
        post :create, donation: {amount: 5}
        expect(response).to have_http_status(:created)
        expect(assigns[:donation]).to eq(donation)
      end
    end
  end

  describe '#show' do
    context 'when donation is found' do
      it 'returns the donation and sets the status to ok' do
        donation = Donation.create(amount: 5)
        stub_donation_finding donation, 1
        get :show, id: 1
        expect(response).to have_http_status(:ok)
        expect(assigns[:donation]).to eq(donation)
      end
    end
    context 'when donation is not found' do
      it 'returns the error and the status not found' do
        get :show, id: 2
        Rails.logger.warn "***RESPONSE #{response.inspect}"
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  def stub_donation_finding(donation, id)
    allow(Donation).to receive(:find).
      with(id.to_s).
      and_return(donation)
  end

  def stub_donation_creation(donation)
    allow(donation).to receive(:save).and_return(true)
    allow(Donation).to receive(:new).
      with('amount' => '5').
      and_return(donation)
  end

end
