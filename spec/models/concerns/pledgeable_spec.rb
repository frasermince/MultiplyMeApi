require 'rails_helper'

RSpec.configure do |c|
  c.include DonationCreator
  c.include DonationAmounts
end

RSpec.describe Pledgeable do
  describe '#find_cycle' do
    context 'does not have an ancestor from the same user' do
      it 'returns nil' do
        create_different_user_donations
        expect(@third_child.parent.find_cycle(@third_child.user)).to be_nil
      end
    end
    context 'does have an ancestor donation from the same user' do

      it 'returns this ancestor' do
        create_two_children
        expect(@child_donation.parent.find_cycle(@child_donation.user)).to eq(@parent_donation)
      end
    end
  end

  describe '#user_cycles?' do
    context 'parent is nil' do
      it 'returns false' do
        create_parent
        expect(@parent_donation.user_cycles?).to be_falsey
      end
    end
    context 'find_cycle returns a donation' do
      it 'returns true' do
        create_one_child
        allow_any_instance_of(Donation).to receive(:find_cycle).and_return(@parent_donation)
        expect(@child_donation.user_cycles?).to be_truthy
      end
      context 'find_cycle returns nil' do
        it 'returns false' do
          create_one_child
          allow_any_instance_of(Donation).to receive(:find_cycle).and_return(nil)
          expect(@child_donation.user_cycles?).to be_falsey
        end
      end
    end
  end

  describe '#yearly_amount' do
    context 'donation is a subscription' do
      it "returns the donation's amount multiplyed by twelve" do
        donation = create(:subscription_donation)
        expect(donation.yearly_amount).to eq(donation.amount * 12)
      end
    end
    context 'donation is not a subscription' do
      it "returns the donation's amount" do
        donation = create(:nonsubscription_donation)
        expect(donation.yearly_amount).to eq(donation.amount)
      end
    end
  end

  describe '#subscription_length' do
    context 'is a subscription' do
      it 'calculates the amount of months' do
        donation = create(:parent)
        expect(donation.subscription_length(1.month.ago)).to eq(1)
      end
    end
    context 'is not a subscription' do
      it 'returns 0' do
        donation = create(:nonsubscription_donation)
        expect(donation.subscription_length(1.month.ago)).to eq(0)
      end
    end
  end

  describe '#delete_subscription' do
    context 'donation is a subscription' do
      it 'deletes the subscription' do
        donation = create(:stripe_donation)
        payment_service = PaymentService.new(donation)
        payment_service.create_subscription
        expect_any_instance_of(Stripe::Subscription).to receive(:delete)
        expect{donation.delete_subscription}.not_to raise_error
        expect(donation.is_cancelled).to eq(true)
      end
    end
    context 'donation is not a subscription or is not paid' do
      it 'does nothing' do
        donation = create(:unpaid_stripe_donation)
        expect_any_instance_of(Stripe::Subscription).not_to receive(:delete)
        donation.delete_subscription
      end
    end
  end
end
