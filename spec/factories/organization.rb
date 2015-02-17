FactoryGirl.define do
  factory :organization do
    stripe_access_token Rails.application.secrets.stripe_secret_key
    name 'test'
    factory :invalid_organization do
      stripe_access_token '12345'
    end
  end
end
