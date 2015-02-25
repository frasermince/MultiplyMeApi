FactoryGirl.define do
  factory :user do
    email 'test@test.com'
    uid 'testtest'
    password 'testtest'
    provider 'email'
    factory :stripe_user do
      after(:build) do |user|
        Stripe.api_key = Rails.application.secrets.stripe_secret_key
        token = Stripe::Token.create(
          card: {
            :number => "4242424242424242",
            :exp_month => 2,
            :exp_year => 2016,
            :cvc => "314"
          }
        )
        user.save_stripe_user user.email, token.id
      end
    end
  end

end

