module StripeHelpers
  def create_token_object(card=4242424242424242)
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    VCR.use_cassette('create_stripe_token', :record => :all) do
      Stripe::Token.create(
        card: {
          :number => card,
          :exp_month => 2,
          :exp_year => 2016,
          :cvc => "314"
        }
      )
    end
  end

  def create_token(card=4242424242424242)
    create_token_object(card).id
  end
end
