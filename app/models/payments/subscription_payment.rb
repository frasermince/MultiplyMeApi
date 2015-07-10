module Payments
  class SubscriptionPayment
    def initialize(donation)
      @donation = donation
      @stripe_client = StripeClient.new(donation.organization)
    end

    def pay
      customer = OrganizationsUser.get_stripe_user(@donation.organization, @donation.user)
      @stripe_client.create_subscription(@donation, customer)
    end
  end
end
