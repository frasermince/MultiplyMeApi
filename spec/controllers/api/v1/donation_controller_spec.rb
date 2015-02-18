require 'rails_helper'

RSpec.configure do |c|
  c.include DonationCreator
  c.include DonationAmounts
end

describe Api::V1::DonationsController do
  login_user
  before(:each) do
    @donation = create(:donation)
  end
  describe '#create' do
    context 'when donation is valid' do
      it 'returns the donation and sets the status to created' do
        stub_donation_creation @donation, true
        post :create, donation: donation_attributes, card: card_attributes
        expect(response).to have_http_status(:created)
        expect(assigns[:donation]).to eq(@donation)
      end
    end

    context 'when donation is invalid' do
      it 'returns the error and sets the status to unprocessable' do
        stub_donation_creation @donation, false
        post :create, donation: donation_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe '#show' do
    context 'when donation is found' do
      it 'returns the donation and sets the status to ok' do
        stub_donation_finding @donation, @donation.id
        get :show, id: @donation.id
        expect(response).to have_http_status(:ok)
        expect(assigns[:donation]).to eq(@donation)
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
        stub_donation_finding @donation, @donation.id
        put :update, id: @donation.id, donation: updated_donation_attributes
        expect(response).to have_http_status(:ok)
        expect(assigns[:donation].amount).to eq(updated_donation_attributes[:amount])
      end
    end
    context 'when donation is not updated successfully' do
      it 'returns the error and sets the status to unprocessable' do
        stub_donation_finding @donation, @donation.id
        stub_donation_creation @donation, false
        put :update, id: @donation.id, donation: updated_donation_attributes
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  def donation_attributes
    attributes_for(:donation)
  end

  def updated_donation_attributes
    attributes_for(:updated_donation)
  end

  def card_attributes
    {token: '12345', email: 'test@test.com'}
  end

  def string_params
    donation_params = donation_attributes.map {|k, v| [k.to_s, v.to_s]}.to_h
    donation_params.select{|k, v| k != 'user_id'}
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
