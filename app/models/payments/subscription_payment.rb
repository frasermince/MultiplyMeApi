module Payments
  class SubscriptionPayment
    def initialize(donation)
      @donation = donation
      @stripe_client = StripeClient.new(donation.organization)
    end

    def pay
      unless @donation.is_paid?
        customer = OrganizationsUser.get_stripe_user(@donation.organization, @donation.user)
        @stripe_client.create_subscription(@donation, customer)
        @donation.update_attribute('is_paid', true)
      end
    end
  end
end
