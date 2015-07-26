FactoryGirl.define do
  factory :organization do
    id {Organization.where(id: 2).present? ? Organization.last.try(:id).to_i + 1 : 2}
    stripe_access_token 'sk_test_r4rsH5wxKhgQILkRhHaKhMvu'
    stripe_id 'acct_16EmnOBUbfvWsDJi'
    name 'test'
    factory :invalid_organization do
      stripe_access_token '12345'
    end
  end
end
