require 'rails_helper'

RSpec.describe User, :type => :model do
  it { should have_many(:donations) }

  describe '#save_stripe_user' do
    it 'calls create_stripe_user' do
      user = create(:user)
      allow(user).to receive(:create_stripe_user).and_return(1)
      expect(user).to receive(:create_stripe_user)
      user.save_stripe_user(*valid_stripe_params)
      expect(user.reload.stripe_id).to eq(1)
    end
  end

  describe '#create_stripe_user' do
    it 'successfully saves a stripe user' do
      user = create(:user)
      user.create_stripe_user(*valid_stripe_params)
    end

    it 'fails to create a stripe user' do
      user = create(:user)
      organization = create(:invalid_organization)
      expect{user.create_stripe_user('test@test.com', '12345', organization)}.to raise_error
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
