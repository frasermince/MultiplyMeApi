require 'rails_helper'

RSpec.describe User, :type => :model do
  before(:each) do
    @user = create(:user)
  end
  it { should have_many(:donations) }

  describe '#save_stripe_user' do
    it 'calls create_stripe_user' do
      allow(@user).to receive(:create_stripe_user).and_return("1")
      expect(@user).to receive(:create_stripe_user)
      @user.save_stripe_user(*valid_stripe_params)
      expect(@user.reload.stripe_id).to eq("1")
    end
  end

  describe '#create_stripe_user' do
    it 'successfully saves a stripe user' do
      @user.create_stripe_user(*valid_stripe_params)
    end

    it 'fails to create a stripe user' do
      organization = create(:invalid_organization)
      expect{@user.create_stripe_user('test@test.com', '12345', organization)}.to raise_error
    end
  end

  describe '#add_credit_card' do
    it 'has stripe_id and thus can create card' do
      allow(@user).to receive(:create_credit_card).and_return(true)
      @user.save_stripe_user(*valid_stripe_params)
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
      @user.save_stripe_user(*valid_stripe_params)
      expect{@user.create_credit_card create_token}.not_to raise_error
    end

    it 'fails to create credit card because token is invalid' do
      @user.save_stripe_user(*valid_stripe_params)
      expect{@user.create_credit_card '12345'}.to raise_error
    end

    it 'fails to create credit card because token is invalid' do
      expect{@user.create_credit_card create_token}.to raise_error
    end
  end

  def valid_stripe_params
      organization = create(:organization)
      ['test@test.com', create_token, organization]
  end

  def create_token
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    response = Stripe::Token.create(
      card: {
        :number => "4242424242424242",
        :exp_month => 2,
        :exp_year => 2016,
        :cvc => "314"
      }
    )
    response.id
  end
end
