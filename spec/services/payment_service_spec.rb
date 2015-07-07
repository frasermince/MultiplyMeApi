require 'rails_helper'

RSpec.describe PaymentService do

  before(:each) do
    @stripe_client = StripeClient.new
    allow(StripeClient).to receive(:new).and_return(@stripe_client)
  end

  describe '#purchase' do
    context 'succeeds in making a purchase' do

      context 'and donation is a subscription' do
        it 'calls create_subscription' do
          donation = create(:donation)
          donation.is_subscription = true
          payment_service = PaymentService.new donation
          allow(@stripe_client).to receive(:create_subscription)

          payment_service.purchase
          expect(@stripe_client).to have_received(:create_subscription)
        end
      end

      context 'and donation is not a subscription' do
        it 'calls create_charge' do
          donation = create(:donation)
          donation.is_subscription = false
          allow(@stripe_client).to receive(:create_charge)
          payment_service = PaymentService.new donation
          payment_service.purchase
          expect(@stripe_client).to have_received(:create_charge)
        end
      end

      it 'returns a status of success' do
        #allow_any_instance_of(PaymentService).to receive(:create_subscription).and_return({status: true})
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
