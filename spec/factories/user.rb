FactoryGirl.define do
  factory :user do
    email 'fraser@multiplyme.in'
    factory :wrong_email_user do
      email 'WRONG'
    end
    uid 'testtest'
    password 'testtest'
    provider 'email'
    factory :second_user do
      email 'other@multiplyme.in'
    end
    factory :third_user do
      email 'third@multiplyme.in'
    end
    factory :fourth_user do
      email 'fourth@multiplyme.in'
    end
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
        user.save_stripe_user({email: user.email, token: token.id})
      end
    end
  end

end

