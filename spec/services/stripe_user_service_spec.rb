require 'rails_helper'

RSpec.configure do |c|
  c.include StripeHelpers
end

RSpec.describe StripeUserService do
  before(:each) do
    @user = create(:user)
    @stripe_client = StripeClient.new
    allow(StripeClient).to receive(:new).and_return(@stripe_client)
    @stripe_user_service = StripeUserService.new @user
  end

  describe '#save_stripe_user' do
    it 'calls create_stripe_user' do
      allow(@stripe_user_service).to receive(:create_stripe_user).and_return(1)
      @stripe_user_service.save_stripe_user(valid_stripe_params)
      expect(@stripe_user_service).to have_received(:create_stripe_user)
      expect(@user.reload.stripe_id).to eq("1")
    end
  end

  describe '#add_credit_card' do
    it 'has stripe_id and thus can create card' do
      allow(@stripe_client).to receive(:create_credit_card).and_return(true)
      VCR.use_cassette('save_stripe_user') do
        @stripe_user_service.save_stripe_user(valid_stripe_params)
      end

      result = VCR.use_cassette('add_credit_card') do
        @stripe_user_service.add_credit_card create_token
      end
      expect(result).to eq(true)
    end

    it 'does not have a stripe_id and thus fails' do
      allow(@stripe_client).to receive(:create_credit_card).and_return(true)
      result = @stripe_user_service.add_credit_card create_token
      expect(result).to be_falsey
    end
  end

end
