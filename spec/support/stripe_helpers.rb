module StripeHelpers
  def fetch_stripe_user(user)
    VCR.use_cassette('retrieve_helper') do
      StripeClient.new.retrieve_stripe_user(user)
    end
  end

  def create_stripe_user(organization=nil)
    VCR.use_cassette('create_user_helper') do
      StripeClient.new(organization).create_stripe_user({
        token: create_token,
        email: 'test@test.com'
      })
    end
  end

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

  def valid_stripe_params(card=4242424242424242)
    {email: 'test@test.com', token: create_token(card)}
  end
end
