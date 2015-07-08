class PaymentService
  def initialize(donation, organization)
    @donation = donation
    @stripe_client = StripeClient.new(organization)
  end

  def purchase
    if @donation.is_paid
      false
    else
      pay_by_stripe_user
    end
  end

  private
  def pay_by_stripe_user
    customer = get_stripe_user
    subscribe_or_donate(customer)
    @donation.update(is_paid: true)
    true
  end

  def get_stripe_user
    OrganizationsUser
      .find_or_create(@donation.organization_id, @donation.user_id)
      .get_stripe_user
  end

  def subscribe_or_donate(customer)
    if @donation.is_subscription
      @stripe_client.create_subscription(@donation, customer)
    else
      @stripe_client.create_charge(@donation, customer)
    end
  end
end
