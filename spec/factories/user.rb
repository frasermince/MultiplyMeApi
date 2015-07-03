FactoryGirl.define do
  factory :user do
    name 'Fraser Mince'
    sequence(:email){|n| "user#{n}@factory.com" }
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
        stripe_user_service = StripeUserService.new(user)
        stripe_user_service.save_stripe_user({email: user.email, token: token.id})
      end
    end
  end

end

