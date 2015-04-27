require 'rails_helper'

RSpec.configure do |c|
  c.include DonationAmounts
  c.include DonationCreator
  c.include Stubber
  c.include StripeHelpers
end

describe Api::V1::DonationsController do
  login_user
  before(:each) do
    @donation = create(:donation)
  end
  before { allow(controller).to receive(:current_user) { @user } }
  describe '#create' do
    context 'when donation is valid' do
      it 'returns the donation and sets the status to created' do
        stub_creation @donation, true
        expect_stripe_user @donation
        post :create, donation: donation_attributes, card: valid_card_attributes
        expect(response).to have_http_status(:created)
        expect(assigns[:donation]).to eq(@donation)
      end
    end

    context 'when subscribe is true' do
      it 'adds user to mailing list' do
        stub_creation @donation, true
        allow(@user).to receive(:mailing_subscribe)
        expect(@user).to receive(:mailing_subscribe)
        post :create, subscribe: true, donation: donation_attributes, card: valid_card_attributes
        expect(response).to have_http_status(:created)
      end
    end

    context 'when donation is invalid' do
      it 'returns the error and sets the status to unprocessable' do
        stub_creation @donation, false
        post :create, donation: donation_attributes, card: {email: 'test@test.com', token: '12345'}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when card is fake or not present' do
      it 'Does not save and sets status to unprocessable' do
        count = Donation.count
        stub_creation @donation, true
        post :create, donation: donation_attributes, card: {fake: 'fake'}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(count).to eq(Donation.count)
      end
    end
  end

  describe '#show' do
    context 'when donation is found' do
      it 'returns the donation and sets the status to ok' do
        stub_finding @donation, @donation.id
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
        stub_finding @donation, @donation.id
        put :update, id: @donation.id, donation: updated_donation_attributes
        expect(response).to have_http_status(:ok)
        expect(assigns[:donation].amount).to eq(updated_donation_attributes[:amount])
      end
    end
    context 'when donation is not updated successfully' do
      it 'returns the error and sets the status to unprocessable' do
        stub_finding @donation, @donation.id
        stub_creation @donation, false
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

  def valid_card_attributes
    {token: create_token, email: 'test@test.com'}
  end

  def string_params
    donation_params = donation_attributes.map {|k, v| [k.to_s, v.to_s]}.to_h
    donation_params.select{|k, v| k != 'user_id'}
  end
end
