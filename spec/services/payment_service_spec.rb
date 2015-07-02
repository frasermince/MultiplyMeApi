require 'rails_helper'

RSpec.configure do |c|
  c.include DonationCreator
  c.include DonationAmounts
end

RSpec.describe PaymentService do

  describe '#create_subscription' do
    context 'has a nil stripe id' do
      it 'throws an exception' do
        create_parent
        payment_service = PaymentService.new @parent_donation
        result = payment_service.create_subscription
        expect(result).to eq(false)
      end
    end
    context 'has a valid stripe id' do
      it 'creates a subscription' do
        donation = create(:stripe_donation)
        payment_service = PaymentService.new donation
        result = payment_service.create_subscription
        expect(result).to eq(true)
        expect(donation.reload.stripe_id).to be
      end
    end
  end

  describe '#create_charge' do
    context 'has a nil stripe id' do
      it 'throws an exception' do
        create_parent
        payment_service = PaymentService.new @parent
        expect(payment_service.create_charge).to eq(false)
      end
    end
    context 'has a valid stripe id' do
      it 'creates a charge' do
        donation = create(:stripe_donation)
        payment_service = PaymentService.new donation
        expect(payment_service.create_charge).to eq(true)
        expect(donation.reload.stripe_id).to be
      end
    end
  end

  describe '#purchase' do
    context 'succeeds in making a purchase' do

      context 'and donation is a subscription' do
        it 'calls create_subscription' do
          donation = create(:subscription_donation)
          expect_any_instance_of(PaymentService).to receive(:create_subscription)
          payment_service = PaymentService.new donation
          payment_service.purchase
        end
      end

      context 'and donation is not a subscription' do
        it 'calls create_charge' do
          donation = create(:nonsubscription_donation)
          expect_any_instance_of(PaymentService).to receive(:create_charge)
          payment_service = PaymentService.new donation
          payment_service.purchase
        end
      end

      it 'returns a status of success' do
        allow_any_instance_of(PaymentService).to receive(:create_subscription).and_return({status: true})
        create_parent
        payment_service = PaymentService.new @parent_donation
        expect(payment_service.purchase).to be_truthy
      end
    end

    context 'purchase was previously made' do
      it 'returns a failed status' do
        create_paid
        payment_service = PaymentService.new @paid_donation
        expect(payment_service.purchase).to eq(false)
      end
    end

  end
end
