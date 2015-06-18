class PaymentService
  def initialize(donation)
    @donation = donation
  end

  def pay
    parent = @donation.parent
    unless @donation.is_challenged
      response = self.purchase
      if response[:status] == :failed
        raise Exception.new(response[:error])
      end
      response
    end
    policy = CompletedChallengePolicy.new parent
    if parent.present? && policy.challenge_completed?
      self.purchase
    end
  end

  def purchase
    unless @donation.is_paid
      response = @donation.is_subscription ? self.create_subscription : self.create_charge
      @donation.update(is_paid: true) if response[:status] == :success
      return response
    end
    return {status: :failed, error: 'order has already been paid'}
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
      return {status: :failed, error: error}
    end
    {status: :success}
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
      return {status: :failed, error: error}
    end
    {status: :success}
  end
end
