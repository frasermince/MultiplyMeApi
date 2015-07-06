class StripeClient
  def initialize

  end

  def create_stripe_user(params)
      Stripe.api_key = Rails.application.secrets.stripe_secret_key
      customer = Stripe::Customer.create(
        {
          source: params[:token],
          email: params[:email]
        }
      )
    customer
  end

  def retrieve_stripe_user(user)
    Stripe::Customer.retrieve(user.stripe_id)
  end

  def create_credit_card(token, user)
    customer = self.retrieve_stripe_user user
    customer.sources.create(:source => token)
  end
end
