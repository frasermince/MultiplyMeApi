class PaymentService
  def initialize(donation)
    @donation = donation
    @stripe_client = StripeClient.new
  end

  def purchase
    if @donation.is_paid
      false
    else
      customer = get_stripe_user
      @donation.is_subscription ? @stripe_client.create_subscription(customer) : @stripe_client.create_charge(customer)
      @donation.update(is_paid: true)

    end
  end

  private
  def get_stripe_user
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    organizations_user = OrganizationsUser.find_or_create(@donation.organization_id, @donation.user_id)
    organizations_user.get_stripe_user
  end
end
