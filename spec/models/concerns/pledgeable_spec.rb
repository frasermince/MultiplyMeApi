require 'rails_helper'

RSpec.describe Pledgeable do
  describe '#after_create' do
    context 'if it is a challenge' do
      it 'does not create a purchase for self' do
        allow_any_instance_of(Donation).to receive(:purchase).and_return(nil)
        expect_any_instance_of(Donation).not_to receive(:purchase)
        create_parent
      end
    end

    context 'if it is not a challenge' do
      it 'does create a purchase for self' do
        allow_any_instance_of(Donation).to receive(:purchase).and_return(nil)
        expect_any_instance_of(Donation).to receive(:purchase)
        create_parent false
      end
    end

    context 'if it has three children and is not paid' do
      it 'does call purchase' do
        allow_any_instance_of(Donation).to receive(:purchase).and_return(true)
        expect_any_instance_of(Donation).to receive(:purchase)
        create_three_children
      end
    end
  end

  describe '#create_charge' do
    context 'has an nil stripe id' do
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
