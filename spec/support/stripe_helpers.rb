module StripeHelpers
  def create_token_object
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    response = Stripe::Token.create(
      card: {
        :number => "4242424242424242",
        :exp_month => 2,
        :exp_year => 2016,
        :cvc => "314"
      }
    )
    response
  end

  def create_token
    create_token_object.id
  end
end
