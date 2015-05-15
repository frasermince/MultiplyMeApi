require 'rails_helper'

RSpec.configure do |c|
    c.include DonationCreator
    c.include DonationAmounts
end

RSpec.describe Pledgeable do
  describe '#after_create' do
    context 'receives a challenge' do
      it 'does not create a purchase for self' do
        allow_any_instance_of(Donation).to receive(:purchase).and_return(nil)
        expect_any_instance_of(Donation).not_to receive(:purchase)
        create_parent
      end

      context 'challenge_completed? is true' do
        it 'does call purchase' do
          #should stub challenge_completed but this causes a strange error
          #allow_any_instance_of(Donation)
          #  .to receive(:challenge_completed?)
          #  .and_return(true)

          allow_any_instance_of(Donation)
            .to receive(:purchase)
            .and_return(true)

          expect_any_instance_of(Donation)
            .to receive(:purchase)

          create_three_children
        end
      end

      context 'challenge_completed? is false' do
        it 'does not call purchase' do

          allow_any_instance_of(Donation)
            .to receive(:challenge_completed?)
            .and_return(false)

          allow_any_instance_of(Donation)
            .to receive(:purchase)
            .and_return(true)

          expect_any_instance_of(Donation)
            .not_to receive(:purchase)
          create_one_child
        end
      end

    end

    context 'if it is a challenge' do
      it 'sends a registration email and a notification email' do
        allow_any_instance_of(Donation)
          .to receive(:purchase).and_return(nil)
        expect {create_parent}
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'if it is not a challenge' do
      it 'does create a purchase for self' do
        allow_any_instance_of(Donation).to receive(:purchase).and_return(nil)
        expect_any_instance_of(Donation).to receive(:purchase)
        create_parent false
      end

      it 'only sends a registration email' do
        allow_any_instance_of(Donation).to receive(:purchase).and_return(nil)
        expect {create_parent(false)}
          .to change { ActionMailer::Base.deliveries.count }.by(0)
      end

    end

  end

  describe '#challenge_completed?' do
    context 'has three children and is less than three days old' do
      it 'returns true' do
        allow_any_instance_of(Donation)
          .to receive(:purchase)
          .and_return(true)
        create_three_children
        expect(@parent_donation.challenge_completed?).to be_truthy
      end
    end

    context 'is more than three days old' do
      it 'returns false' do
        allow_any_instance_of(Donation)
          .to receive(:purchase)
          .and_return(true)
        create_three_children true
        expect(@parent_donation.challenge_completed?).to be_falsey
      end
    end

    context 'has less than three children' do
      it 'returns false' do
        allow_any_instance_of(Donation)
          .to receive(:purchase)
          .and_return(true)
        create_two_children
        expect(@parent_donation.challenge_completed?).to be_falsey
      end
    end
  end

  describe '#create_subscription' do
    context 'has a nil stripe id' do
      it 'throws an exception' do
        create_parent
        expect{@parent.create_subscription}.to raise_error
      end
    end
    context 'has a valid stripe id' do
      it 'creates a subscription' do
        donation = create(:stripe_donation)
        expect{donation.create_subscription}.not_to raise_error
        expect(donation.reload.stripe_id).to be
      end
    end
  end

  describe '#create_charge' do
    context 'has a nil stripe id' do
      it 'throws an exception' do
        create_parent
        expect{@parent.create_charge}.to raise_error
      end
    end
    context 'has a valid stripe id' do
      it 'creates a charge' do
        donation = create(:stripe_donation)
        expect{donation.create_charge}.not_to raise_error
        expect(donation.reload.stripe_id).to be
      end
    end
  end

  describe '#update_amounts' do
    it 'calls several functions to update amounts' do
      donation = create(:parent)
      allow_any_instance_of(User).to receive(:add_to_impact)
      expect_any_instance_of(User).to receive(:add_to_impact)
      allow_any_instance_of(User).to receive(:add_to_recurring)
      expect_any_instance_of(User).to receive(:add_to_recurring)
      allow_any_instance_of(Organization).to receive(:add_to_supporters)
      expect_any_instance_of(Organization).to receive(:add_to_supporters)
      donation.update_amounts
    end
  end

  describe '#purchase' do
    context 'succeeds in making a purchase' do

      context 'and donation is a subscription' do
        it 'calls create_subscription' do
          donation = create(:subscription_donation)
          allow_any_instance_of(Donation).to receive(:create_subscription).and_return(true)
          expect_any_instance_of(Donation).to receive(:create_subscription)
          donation.purchase
        end
      end

      context 'and donation is not a subscription' do
        it 'calls create_charge' do
          donation = create(:nonsubscription_donation)
          allow_any_instance_of(Donation).to receive(:create_charge).and_return(true)
          expect_any_instance_of(Donation).to receive(:create_charge)
          donation.purchase
        end
      end

      it 'adds to the impact' do
        donation = create(:subscription_donation)
        allow_any_instance_of(Donation).to receive(:create_subscription).and_return(true)
        allow_any_instance_of(User).to receive(:add_to_impact).and_return(true)
        expect_any_instance_of(User).to receive(:add_to_impact)
        donation.purchase

      end

      it 'returns true' do
        allow_any_instance_of(Donation).to receive(:create_subscription).and_return(true)
        create_parent
        expect(@parent_donation.purchase).to be_truthy
      end
    end

    context 'purchase was previously made' do
      it 'returns false' do
        create_paid
        expect(@paid_donation.purchase).to be_falsey
      end
    end

  end

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
        donation.create_subscription
        expect_any_instance_of(Stripe::Subscription).to receive(:delete)
        expect{donation.delete_subscription}.not_to raise_error
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
