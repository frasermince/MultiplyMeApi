require "stripe"
class Plan
  def create_plan
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    Stripe::Plan.create(
      amount: 1,
      interval: 'month',
      name: 'pledge',
      currency: 'usd',
      id: 'pledge'
    )
  end
end
