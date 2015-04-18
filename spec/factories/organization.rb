FactoryGirl.define do
  factory :organization do
    stripe_access_token 'sk_test_PAI3hO1ytkwgwacLRfee4si6'
    stripe_id 'acct_15mAbCJlTq8enfvW'
    name 'test'
    donation_amount 500000
    donation_count 5
    factory :invalid_organization do
      stripe_access_token '12345'
    end
  end
end
