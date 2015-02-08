require 'rails_helper'

describe Api::V1::DonationsController do
  login_user
  describe '#create' do
    context 'when donation is valid' do
      it 'returns the donation and sets the status to created' do
        donation = Donation.create donation_params
        stub_donation_creation donation, true
        post :create, donation: donation_params
        expect(response).to have_http_status(:created)
        expect(assigns[:donation]).to eq(donation)
      end
    end
    context 'when donation is invalid' do
      it 'returns the error and sets the status to unprocessable' do
        donation = Donation.create donation_params
        stub_donation_creation donation, false
        post :create, donation: donation_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#show' do
    context 'when donation is found' do
      it 'returns the donation and sets the status to ok' do
        donation = Donation.create donation_params
        stub_donation_finding donation, 1
        get :show, id: 1
        expect(response).to have_http_status(:ok)
        expect(assigns[:donation]).to eq(donation)
      end
    end

    context 'when donation is not found' do
      it 'returns the error and sets the status to not found' do
        get :show, id: 2
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe '#update' do
    context 'when donation is updated successfully' do
      it 'returns the donation and sets the status to ok' do
        donation = Donation.create amount: 4
        stub_donation_finding donation, 1
        put :update, id: 1, donation: donation_params
        expect(response).to have_http_status(:ok)
        expect(assigns[:donation].amount).to eq(donation_params[:amount])
      end
    end
    context 'when donation is not updated successfully' do
      it 'returns the error and sets the status to unprocessable' do
        donation = Donation.create amount: 4
        stub_donation_finding donation, 1
        stub_donation_creation donation, false
        put :update, id: 1, donation: donation_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  def donation_params
    {amount: 5, user_id: 1, organization_id: 1}
  end

  def string_params
    donation_params.map { |k, v| [k.to_s, v.to_s] }.to_h
  end

  def stub_donation_finding(donation, id)
    allow(Donation).to receive(:find).
      with(id.to_s).
      and_return(donation)
  end

  def stub_donation_creation(donation, is_saved)
    allow(donation).to receive(:save).and_return(is_saved)
    allow(Donation).to receive(:new).
      with(string_params).
      and_return(donation)
  end

end
