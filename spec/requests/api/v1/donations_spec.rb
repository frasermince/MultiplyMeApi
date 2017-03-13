require 'rails_helper'
RSpec.configure do |c|
  c.include StripeHelpers
end

RSpec.describe 'Donation API', :type => :request do
  before { host! "api.multiplyme.in" }
  describe 'POST' do
    context 'donation is third child of a challenged' do
      it 'successfully returns the donation' do
        parent = create(:stripe_donation)
        first_child = create(:donation)
        second_child = create(:donation)
        parent.update_attribute('is_challenged', true)
        referral_code = 'test'
        parent.update_attribute('referral_code', referral_code)
        first_child.update_attribute('parent_id', parent.id)
        second_child.update_attribute('parent_id', parent.id)

        call_donation_create referral_code

        expect(json['error']).not_to be
      end
    end

    context 'information is valid' do
      context 'referral is present' do
        it 'sets the parent donation based on the referral' do
          parent = create(:donation)
          parent.update_attribute 'referral_code', 'test'
          call_donation_create 'test'
          expect(json['donation']['parent_id']).to eq(parent.id)
        end
      end

      context 'referral code is nil' do
        it 'returns the donation and a status of 200' do
          call_donation_create
          expect(response).to be_success
          expect(json['donation']['amount']).to eq(attributes_for(:donation)[:amount])
        end
      end
    end

    context 'authentication token is not present' do
      it 'responds with an error saying the user is not authorized' do

        donation_attributes = attributes_for(:donation)
        card_params = valid_stripe_params
        subscribe = false
        post '/v1/donations', {donation: donation_attributes, card: card_params, subscribe: subscribe}
        expect(json['errors']).to eq ['Authorized users only.']
      end
    end

    context 'stripe token is declined on charge' do
      it 'returns the error' do
        call_donation_create(nil, 4000000000000341)
        expect(json['error']).to eq 'Your card was declined.'
      end
    end

    context 'stripe token is declined on customer save' do
      it 'returns the error' do
        call_donation_create(nil, 4000000000000002)
        expect(json['error']).to eq 'Your card was declined.'
      end
    end
  end

  context 'stripe token is declined because of fraud' do
    it 'returns the error' do
      call_donation_create(nil, 4100000000000019)
      expect(json['error']).to eq 'Your card was declined.'
    end
  end

  context 'card has the wrong csv' do
    it 'returns the error' do
      call_donation_create(nil, 4000000000000127)
      expect(json['error']).to eq "Your card's security code is incorrect."
    end
  end

  context 'card is expired' do
    it 'returns the error' do
      call_donation_create(nil, 4000000000000069)
      expect(json['error']).to eq 'Your card has expired.'
    end
  end

  context 'a processing error occurs' do
    it 'returns the error' do
      call_donation_create(nil, 4000000000000119)
      expect(json['error']).to eq 'An error occurred while processing your card. Try again in a little bit.'
    end
  end

  def call_donation_create(referral_code=nil, card=4242424242424242)
    user = create(:user)
    auth_headers = user.create_new_auth_token
    donation_attributes = attributes_for(:donation)
    donation_attributes[:is_challenged] = false
    card_params = valid_stripe_params(card)
    subscribe = false
    post '/v1/donations', { donation: donation_attributes, card: card_params, subscribe: subscribe, referral_code: referral_code }, auth_headers
  end
end
