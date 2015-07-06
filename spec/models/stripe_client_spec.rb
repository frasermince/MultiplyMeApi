require 'rails_helper'

RSpec.configure do |c|
  c.include StripeHelpers
end
RSpec.describe StripeClient do

  before(:each) do
    @stripe_client = StripeClient.new
  end

  describe '#create_stripe_user' do
    it 'successfully saves a stripe user' do
      result = VCR.use_cassette('service_create_stripe_user') do
        @stripe_client.create_stripe_user(valid_stripe_params)
      end
      expect(result).not_to be_falsey
    end

    it 'fails to create a stripe user' do
      VCR.use_cassette('failed_stripe_user') do
        expect{@stripe_client.create_stripe_user(email: 'test@test.com', token: '12345')}.to raise_error(Stripe::InvalidRequestError)
      end
    end
  end

  describe '#retrieve_stripe_user' do
    context 'has a valid token' do
      it 'successfully retrieves the stripe user' do
        user = create(:stripe_user)
        VCR.use_cassette('retrieve_user') do
          expect{@stripe_client.retrieve_stripe_user user}.not_to raise_error
        end
      end
    end
    context 'has an invalid user' do
      it 'raises an error' do
        user = create(:user)
        VCR.use_cassette('retrieve_invalid_user') do
          expect{@stripe_client.retrieve_stripe_user user}.to raise_error(Stripe::InvalidRequestError)
        end
      end
    end
  end

  describe '#create_credit_card' do
    it 'successfully creates credit card' do

      user = create(:stripe_user)
      customer = fetch_stripe_user(user)
      allow(@stripe_client)
        .to receive(:retrieve_stripe_user)
        .and_return(customer)

      VCR.use_cassette('create_credit_card') do
        expect{@stripe_client.create_credit_card create_token, user}.not_to raise_error
      end
    end

    it 'fails to create credit card because token is invalid' do
      user = create(:stripe_user)

      customer = fetch_stripe_user(user)
      allow(@stripe_client)
        .to receive(:retrieve_stripe_user)
        .and_return(customer)

      VCR.use_cassette('create_credit_card_invalid_token') do
        expect{@stripe_client.create_credit_card '12345', user}.to raise_error(Stripe::InvalidRequestError)
      end
    end
  end

end
