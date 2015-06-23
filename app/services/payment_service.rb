class PaymentService
  def initialize(donation)
    @donation = donation
    @errors = []
  end

  def purchase
    if @donation.is_paid
      @errors.push 'order has already been paid'
      false
    else
      response = @donation.is_subscription ? self.create_subscription : self.create_charge
      @donation.update(is_paid: true) if response
      response
    end
  end

  def errors
    @errors
  end

  def create_subscription
    begin
      Stripe.api_key = Rails.application.secrets.stripe_secret_key
      customer = @donation.organization.get_stripe_user(@donation.user)
      subscription = customer.subscriptions.create({
        application_fee_percent: PERCENTAGE_FEE,
        plan: 'pledge',
        quantity: @donation.amount,
      }, stripe_account: @donation.organization.stripe_id)
      @donation.update_attribute('stripe_id', subscription.id)
    rescue => error
      @errors = @errors.push error.message
      return false
    end
    true
  end

  def create_charge
    begin
      Stripe.api_key = Rails.application.secrets.stripe_secret_key
      customer = @donation.organization.get_stripe_user(@donation.user)
      charge = Stripe::Charge.create({
        amount: @donation.amount,
        application_fee: (@donation.amount * (PERCENTAGE_FEE / 100.0)).round,
        currency: 'usd',
        customer: customer.id
      }, stripe_account: @donation.organization.stripe_id)
      @donation.update_attribute('stripe_id', charge.id)
    rescue => error
      @errors = @errors.push error.message
      return false
    end
    true
  end
end
