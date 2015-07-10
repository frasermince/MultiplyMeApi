require 'rails_helper'

RSpec.configure do |c|
  c.include StripeHelpers
end

RSpec.describe Payments::SubscriptionPayment do
  describe '#pay' do
    it 'calls stripe client' do
      donation = create(:donation)
      customer = create_stripe_user
      stripe_client = double('stripe_client')
      allow(OrganizationsUser)
        .to receive(:get_stripe_user)
        .and_return(customer)
      allow(StripeClient)
        .to receive(:new)
        .and_return(stripe_client)
      allow(stripe_client)
        .to receive(:create_subscription)
      subscription_payment = Payments::SubscriptionPayment.new(donation)

      subscription_payment.pay
      expect(stripe_client).to have_received(:create_subscription)
    end
  end
end
