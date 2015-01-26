FactoryGirl.define do
  factory :user do
    email 'test@test.com'
    uid 'testtest'
    password 'testtest'
    provider 'email'
  end
end

