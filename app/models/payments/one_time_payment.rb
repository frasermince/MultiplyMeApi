module Payments
  class OneTimePayment
    def initialize(donation)
      @donation = donation
      @stripe_client = StripeClient.new(donation.organization)
    end

    def pay
      customer = OrganizationsUser.get_stripe_user(@donation.organization, @donation.user)
      @stripe_client.create_charge(@donation, customer)
    end
  end
end
