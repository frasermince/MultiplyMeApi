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

  describe '#add_to_impact' do
    context 'user_cycles returns true' do
      it 'does not add to impact' do
        allow_any_instance_of(Donation).to receive(:user_cycles?).and_return(true)
        old_impact = @user.impact
        create_two_children
        @user.add_to_impact @child_donation
        expect(@user.reload.impact).to eq(old_impact)
      end
    end

    context 'user_cycles returns false' do
      it 'adds the impact of this donation to the user' do
        allow_any_instance_of(Donation).to receive(:user_cycles?).and_return(false)
        old_impact = @user.impact
        create_different_user_donations
        @user.add_to_impact @first_child
        expect(@user.reload.impact).to eq(old_impact + @first_child.amount + @first_child.downline_amount)
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
