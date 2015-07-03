require 'rails_helper'

RSpec.configure do |c|
  c.include StripeHelpers
end

RSpec.describe StripeUserService do
  before(:each) do
    @user = create(:user)
    @stripe_user_service = StripeUserService.new @user
  end

  describe '#save_stripe_user' do
    it 'calls create_stripe_user' do
      allow(@stripe_user_service).to receive(:create_stripe_user).and_return(1)
      expect(@stripe_user_service).to receive(:create_stripe_user)
      @stripe_user_service.save_stripe_user(valid_stripe_params)
      expect(@user.reload.stripe_id).to eq("1")
    end
  end

  describe '#create_stripe_user' do
    it 'successfully saves a stripe user' do
      result = VCR.use_cassette('service_create_stripe_user') do
        @stripe_user_service.create_stripe_user(valid_stripe_params)
      end
      expect(result).not_to be_falsey
    end

    it 'fails to create a stripe user' do
      VCR.use_cassette('failed_stripe_user') do
        expect(@stripe_user_service.create_stripe_user(email: 'test@test.com', token: '12345')).to be_falsey
      end
      expect(@stripe_user_service.errors).not_to be_empty
    end
  end

  describe '#add_credit_card' do
    it 'has stripe_id and thus can create card' do
      allow(@stripe_user_service).to receive(:create_credit_card).and_return(true)
      VCR.use_cassette('save_stripe_user') do
        @stripe_user_service.save_stripe_user(valid_stripe_params)
      end

      result = VCR.use_cassette('add_credit_card') do
        @stripe_user_service.add_credit_card create_token
      end
      expect(result).to eq(true)
    end

    it 'does not have a stripe_id and thus fails' do
      allow(@stripe_user_service).to receive(:create_credit_card).and_return(true)
      result = @stripe_user_service.add_credit_card create_token
      expect(result).to be_falsey
      expect(@stripe_user_service.errors).not_to be_empty
    end
  end

  describe '#create_credit_card' do
    it 'successfully creates credit card' do

      VCR.use_cassette('save_stripe_user') do
        @stripe_user_service.save_stripe_user(valid_stripe_params)
      end

      VCR.use_cassette('create_credit_card') do
        expect(@stripe_user_service.create_credit_card create_token).not_to be_falsey
      end
    end

    it 'fails to create credit card because token is invalid' do
      @stripe_user_service.save_stripe_user(valid_stripe_params)
      expect(@stripe_user_service.create_credit_card '12345').to be_falsey
      expect(@stripe_user_service.errors).not_to be_empty
    end

    it 'fails to create credit card because stripe_id is invalid' do
      expect(@stripe_user_service.create_credit_card create_token).to be_falsey
      expect(@stripe_user_service.errors).not_to be_empty
    end
  end

  def valid_stripe_params
    {email: 'test@test.com', token: create_token}
  end
end
