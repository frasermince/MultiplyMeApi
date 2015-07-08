require 'rails_helper'

RSpec.configure do |c|
  c.include StripeHelpers
end

RSpec.describe PaymentService do

  before(:each) do
    @stripe_client = StripeClient.new
    allow(StripeClient).to receive(:new).and_return(@stripe_client)
  end

  describe '#purchase' do
    context 'donation is not already paid' do

      context 'and donation is a subscription' do
        it 'calls create_subscription' do
          donation = create(:donation)
          organization = create(:organization)
          organizations_user = create(:organizations_user)
          donation.is_subscription = true
          customer = create_stripe_user
          allow(OrganizationsUser)
            .to receive(:find_or_create)
            .and_return(organizations_user)
          allow(organizations_user)
            .to receive(:get_stripe_user)
            .and_return(customer)

          allow(@stripe_client).to receive(:create_subscription)
          payment_service = PaymentService.new donation, organization

          expect(payment_service.purchase).to eq(true)
          expect(@stripe_client).to have_received(:create_subscription)
        end
      end

      context 'and donation is not a subscription' do
        it 'calls create_charge' do
          donation = create(:donation)
          donation.is_subscription = false
          organization = create(:organization)
          organizations_user = create(:organizations_user)
          payment_service = PaymentService.new donation, organization
          customer = create_stripe_user
          allow(OrganizationsUser)
            .to receive(:find_or_create)
            .and_return(organizations_user)
          allow(organizations_user)
            .to receive(:get_stripe_user)
            .and_return(customer)
          allow(@stripe_client).to receive(:create_charge)

          expect(payment_service.purchase).to eq(true)
          expect(@stripe_client).to have_received(:create_charge).with(any_args, customer)
        end
      end

      context 'payment has already been made' do
        it 'returns a status of success' do
          donation = build_stubbed(:donation)
          donation.is_paid = true
          organization = create(:organization)
          payment_service = PaymentService.new donation, organization
          expect(payment_service.purchase).to be_falsey
        end
      end
    end

    context 'purchase was previously made' do
      it 'returns a failed status' do
        donation = create(:donation)
        organization = create(:organization)
        donation.is_paid = true
        payment_service = PaymentService.new donation, organization
        expect(payment_service.purchase).to eq(false)
      end
    end

  end
end
