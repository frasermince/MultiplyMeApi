require 'rails_helper'

RSpec.configure do |c|
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
        parent_donation = build_stubbed(:donation)
        parent_donation.referral_code = '12345'
        stub_decorator(parent_donation.referral_code)
        post :create, donation: donation_attributes, card: valid_card_attributes, referral_code: parent_donation.referral_code
        parsed_body = JSON.parse(response.body)
        expect(response).to have_http_status(:created)
        expect(parsed_body['donation']['id']).to eq(@donation.id)
      end
    end

    context 'when saving decorator returns error' do
      it 'replies with the error and sets the status to unprocessable' do
        donation_decorator = double('donation_decorator')
        error = 'Your card was declined.'

        allow(DonationDecorator)
          .to receive(:new)
          .and_return(donation_decorator)

        allow(donation_decorator)
          .to receive(:save!)
          .and_raise error


        post :create, donation: donation_attributes, card: invalid_card_attributes
        parsed_body = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body['error']).to eq(error)
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
        updated_amount = 400
        stub_finding @donation, @donation.id
        put :update, id: @donation.id, donation: {amount: updated_amount}
        expect(response).to have_http_status(:ok)
        expect(assigns[:donation].amount).to eq(updated_amount)
      end
    end
    context 'when donation is not updated successfully' do
      it 'returns the error and sets the status to unprocessable' do
        updated_amount = 400
        stub_finding @donation, @donation.id
        stub_creation @donation, false
        put :update, id: @donation.id, donation: {amount: updated_amount}
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  def donation_attributes
    attributes_for(:donation)
  end

  def valid_card_attributes
    {token: create_token, email: 'test@test.com'}
  end

  def invalid_card_attributes
    {token: create_token('4000000000000002'), email: 'test@test.com'}
  end

  def stub_decorator(referral_code)
    donation_decorator = double('donation_decorator')
    allow(DonationDecorator)
      .to receive(:new)
      .with(any_args, referral_code)
      .and_return(donation_decorator)
    allow(donation_decorator)
      .to receive(:save!)
      .and_return(true)
    allow(donation_decorator)
      .to receive(:donation)
      .and_return(@donation)
  end

  def string_params
    donation_params = donation_attributes.map {|k, v| [k.to_s, v.to_s]}.to_h
    donation_params.select{|k, v| k != 'user_id'}
  end
end
