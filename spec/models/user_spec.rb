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

  describe '#add_to_impact' do
    context 'user_cycles returns true' do
      it 'does not add to network_impact' do
        allow_any_instance_of(Donation).to receive(:user_cycles?).and_return(true)
        old_personal_impact = @user.personal_impact
        old_network_impact = @user.network_impact
        create_two_children
        @user.add_to_impact @child_donation
        expect(@user.reload.personal_impact).to eq(old_personal_impact + @child_donation.yearly_amount)
        expect(@user.reload.network_impact).to eq(old_network_impact)
      end
    end

    context 'user_cycles returns false' do
      it 'adds the impact of this donation to the user' do
        allow_any_instance_of(Donation).to receive(:user_cycles?).and_return(false)
        old_personal_impact = @user.personal_impact
        old_network_impact = @user.network_impact
        create_different_user_donations
        @user.add_to_impact @first_child
        expect(@user.reload.personal_impact).to eq(old_personal_impact + @first_child.yearly_amount)
        expect(@user.reload.network_impact).to eq(old_network_impact + @first_child.downline_amount)
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

  describe 'add_to_recurring' do
    context 'is a subcription donation' do
      it 'adds the amount of the donation to recurring_amount' do
        donation = create(:subscription_donation )
        previous_recurring_amount = @user.recurring_amount
        @user.add_to_recurring donation
        expect(@user.recurring_amount).to eq(previous_recurring_amount + donation.amount)
      end
    end

    context 'is not a subcription donation' do
      it 'does not change the recurring_amount' do
        donation = create(:nonsubscription_donation)
        previous_recurring_amount = @user.recurring_amount
        @user.add_to_recurring donation
        expect(@user.recurring_amount).to eq(previous_recurring_amount)
      end
    end
  end

  describe '#update_recurring' do
    it 'removes the amount specified in yearly_amount and adds for the amount of months' do
      donation = create(:parent)
      old_amount = @user.recurring_amount
      @user.update_recurring(donation, 800)
      expect(@user.reload.recurring_amount).to eq(old_amount - donation.amount + 800)
    end
  end

  describe '#update_impact' do
    it 'removes the amount specified in yearly_amount and adds for the amount of months' do
      donation = create(:parent)
      old_amount = @user.personal_impact
      @user.update_impact(donation, 800)
      expect(@user.reload.personal_impact).to eq(old_amount - donation.yearly_amount + 800)
    end
  end



  def valid_stripe_params
    {email: 'test@test.com', card: create_token}
  end

end
