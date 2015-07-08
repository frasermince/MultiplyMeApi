class StripeClient
  def initialize(organization=nil)
    if organization.present?
      @organization = organization
      @secret_key = organization.stripe_access_token
    else
      @secret_key = Rails.application.secrets.stripe_secret_key
    end
  end

  def create_subscription(donation, customer)
    subscription = customer.subscriptions
      .create(subscription_params(donation), stripe_account: @organization.stripe_id)
    donation.update_attribute('stripe_id', subscription.id)
  end

  def create_charge(donation, customer)
    charge = Stripe::Charge
      .create(charge_params(customer, donation), stripe_account: @organization.stripe_id)
    donation.update_attribute('stripe_id', charge.id)
  end

  def create_stripe_token(customer_id)
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    token = Stripe::Token.create(
      { customer: customer_id},
      @secret_key
    )
    token.id
  end

  def create_stripe_user(params)
    Stripe.api_key = @secret_key
    customer = Stripe::Customer.create(
      {
        source: params[:token],
        email: params[:email]
      }
    )
    customer
  end

  def retrieve_stripe_user(user)
    Stripe.api_key = @secret_key
    Stripe::Customer.retrieve(user.stripe_id)
  end

  def create_credit_card(token, user)
    Stripe.api_key = @secret_key
    customer = self.retrieve_stripe_user user
    customer.sources.create(:source => token)
  end

  private
  def subscription_params(donation)
    {
      application_fee_percent: PERCENTAGE_FEE,
      plan: 'pledge',
      quantity: donation.amount,
    }
  end

  def charge_params(customer, donation)
    {
      amount: donation.amount,
      application_fee: (donation.amount * (PERCENTAGE_FEE / 100.0)).round,
      currency: 'usd',
      customer: customer.id
    }
  end
end
