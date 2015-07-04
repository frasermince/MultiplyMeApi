require 'rails_helper'

RSpec.describe PaymentService do

  describe '#create_subscription' do
    context 'has a nil stripe id' do
      it 'throws an exception' do
        donation = create(:donation)
        payment_service = PaymentService.new donation
        result = VCR.use_cassette('create_subscription_failed') do
          payment_service.create_subscription
        end
        expect(result).to eq(false)
      end
    end
    context 'has a valid stripe id' do
      it 'creates a subscription' do
        donation = create(:stripe_donation)
        payment_service = PaymentService.new donation
        result = VCR.use_cassette('create_subscription') do
          payment_service.create_subscription
        end
        expect(result).to eq(true)
        expect(donation.reload.stripe_id).to be
      end
    end
  end

  describe '#create_charge' do
    context 'has a nil stripe id' do
      it 'returns false' do
        donation = create(:donation)
        payment_service = PaymentService.new donation
        expect(payment_service.create_charge).to eq(false)
      end
    end
    context 'has a valid stripe id' do
      it 'creates a charge' do
        donation = create(:stripe_donation)
        payment_service = PaymentService.new donation
        VCR.use_cassette('create_charge') do
          expect(payment_service.create_charge).to eq(true)
        end
        expect(donation.reload.stripe_id).to be
      end
    end
  end

  describe '#purchase' do
    context 'succeeds in making a purchase' do

      context 'and donation is a subscription' do
        it 'calls create_subscription' do
          donation = create(:donation)
          donation.is_subscription = true
          expect_any_instance_of(PaymentService).to receive(:create_subscription)
          payment_service = PaymentService.new donation
          payment_service.purchase
        end
      end

      context 'and donation is not a subscription' do
        it 'calls create_charge' do
          donation = create(:donation)
          donation.is_subscription = false
          expect_any_instance_of(PaymentService).to receive(:create_charge)
          payment_service = PaymentService.new donation
          payment_service.purchase
        end
      end

      it 'returns a status of success' do
        allow_any_instance_of(PaymentService).to receive(:create_subscription).and_return({status: true})
        donation = create(:donation)
        payment_service = PaymentService.new donation
        expect(payment_service.purchase).to be_truthy
      end
    end

    context 'purchase was previously made' do
      it 'returns a failed status' do
        donation = create(:donation)
        donation.is_paid = true
        payment_service = PaymentService.new donation
        expect(payment_service.purchase).to eq(false)
      end
    end

  end
end
