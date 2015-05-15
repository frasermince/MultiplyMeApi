require 'rails_helper'


RSpec.configure do |c|
  c.include StripeHelpers
  c.include DonationCreator
end

RSpec.describe User, :type => :model do
  before(:each) do
    @user = create(:user)
  end
  it { should have_many(:donations) }
  it { should have_many(:organizations).through(:organizations_user) }

  describe '#mailing_subscribe' do

    context 'when list ID is valid and email is valid' do
      it 'returns OK 200' do
        response = @user.mailing_subscribe 'fe1087b0aa'
        expect(response[:status]).to eq(true)
      end
    end
    context 'when list ID is invalid and email is valid' do
      it 'returns HTTP 500' do
        response = @user.mailing_subscribe 'wrong_id'
        expect(response[:status]).to eq(false)
      end
    end

    context 'when list ID is valid but email is invalid' do
      it 'returns HTTP 500' do
        user = create(:wrong_email_user)
        response = user.mailing_subscribe 'fe1087b0aa'
        expect(response[:status]).to eq(false)
      end
    end

  end

  describe '#save_stripe_user' do
    it 'calls create_stripe_user' do
      allow(@user).to receive(:create_stripe_user).and_return("1")
      expect(@user).to receive(:create_stripe_user)
      @user.save_stripe_user(valid_stripe_params)
      expect(@user.reload.stripe_id).to eq("1")
    end
  end

  describe '#create_stripe_user' do
    it 'successfully saves a stripe user' do
      expect{@user.create_stripe_user(valid_stripe_params)}.not_to raise_error
    end

    it 'fails to create a stripe user' do
      expect{@user.reload.create_stripe_user('test@test.com', '12345')}.to raise_error
    end
  end

  describe '#add_credit_card' do
    it 'has stripe_id and thus can create card' do
      allow(@user).to receive(:create_credit_card).and_return(true)
      @user.save_stripe_user(valid_stripe_params)
      result = @user.add_credit_card create_token
      expect(result).to eq(true)
    end

    it 'does not have a stripe_id and thus fails' do
      allow(@user).to receive(:create_credit_card).and_return(true)
      result = @user.add_credit_card create_token
      expect(result).to eq(false)
    end
  end

  describe '#create_credit_card' do
    it 'successfully creates credit card' do
      @user.save_stripe_user(valid_stripe_params)
      expect{@user.create_credit_card create_token}.not_to raise_error
    end

    it 'fails to create credit card because token is invalid' do
      @user.save_stripe_user(valid_stripe_params)
      expect{@user.create_credit_card '12345'}.to raise_error
    end

    it 'fails to create credit card because stripe_id is invalid' do
      expect{@user.create_credit_card create_token}.to raise_error
    end
  end

  def valid_stripe_params
    {email: 'test@test.com', card: create_token}
  end

end
