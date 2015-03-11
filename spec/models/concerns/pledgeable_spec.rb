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

    context 'if it is not a challenge' do
      it 'does create a purchase for self' do
        allow_any_instance_of(Donation).to receive(:purchase).and_return(nil)
        expect_any_instance_of(Donation).to receive(:purchase)
        create_parent false
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
        donation = create(:old_donation)
        create(:child)
        create(:second_child)
        create(:third_child)
        expect(donation.challenge_completed?).to be_falsy
      end
    end

    context 'has less than three children' do
      it 'returns false' do
        allow_any_instance_of(Donation)
          .to receive(:purchase)
          .and_return(true)
        create_two_children
        expect(@parent_donation.challenge_completed?).to be_falsy
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
end
