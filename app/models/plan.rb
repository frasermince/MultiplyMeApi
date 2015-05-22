require "stripe"
class Plan
  def create_plan
    Stripe.api_key = Organization.last.stripe_access_token
    Stripe::Plan.create(
      amount: 1,
      interval: 'month',
      name: 'pledge',
      currency: 'usd',
      id: 'pledge'
    )
  end
end
