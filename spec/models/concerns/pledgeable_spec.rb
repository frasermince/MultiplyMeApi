require 'rails_helper'

RSpec.describe Pledgeable do
  describe '#find_cycle' do
    context 'does not have an ancestor from the same user' do
      it 'returns nil' do
        parent_donation = create(:donation)
        parent_donation.user_id = create(:user)

        first_level = create(:donation)
        first_level.parent_id = parent_donation.id
        first_level.user_id = create(:user)

        second_level = create(:donation)
        second_level.parent_id = first_level.id
        second_level.user_id = create(:user)

        expect(second_level.parent.find_cycle(second_level.user)).to be_nil
      end
    end
    context 'does have an ancestor donation from the same user' do

      it 'returns this ancestor' do
        parent = create(:donation)

        first_child = create(:donation)
        first_child.parent_id = parent.id

        second_child = create(:donation)
        second_child.parent_id = parent.id

        expect(first_child.parent.find_cycle(first_child.user)).to eq(parent)
      end
    end
  end

  describe '#user_cycles?' do
    context 'parent is nil' do
      it 'returns false' do
        donation = create(:donation)
        expect(donation.user_cycles?).to be_falsey
      end
    end
    context 'find_cycle returns a donation' do
      it 'returns true' do
        parent = create(:donation)
        child = create(:donation)
        child.parent_id = parent.id
        allow_any_instance_of(Donation).to receive(:find_cycle).and_return(parent)
        expect(child.user_cycles?).to be_truthy
      end
      context 'find_cycle returns nil' do
        it 'returns false' do
          parent_donation = build_stubbed(:donation)
          child_donation = build_stubbed(:donation)
          child_donation.parent_id = parent_donation.id
          allow_any_instance_of(Donation).to receive(:find_cycle).and_return(nil)
          expect(child_donation.user_cycles?).to be_falsey
        end
      end
    end
  end

  describe '#yearly_amount' do
    context 'donation is a subscription' do
      it "returns the donation's amount multiplyed by twelve" do
        donation = build_stubbed(:donation)
        donation.is_subscription = true
        expect(donation.yearly_amount).to eq(donation.amount * 12)
      end
    end
    context 'donation is not a subscription' do
      it "returns the donation's amount" do
        donation = build_stubbed(:donation)
        donation.is_subscription = false
        expect(donation.yearly_amount).to eq(donation.amount)
      end
    end
  end

  describe '#subscription_length' do
    context 'is a subscription' do
      it 'calculates the amount of months' do
        donation = create(:donation)
        expect(donation.subscription_length(1.month.ago)).to eq(1)
      end
    end
    context 'is not a subscription' do
      it 'returns 0' do
        donation = build_stubbed(:donation)
        donation.is_subscription = false
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
        donation = build_stubbed(:unpaid_stripe_donation)
        expect_any_instance_of(Stripe::Subscription).not_to receive(:delete)
        donation.delete_subscription
      end
    end
  end
end
