FactoryGirl.define do
  factory :donation do
    organization_id {Organization.first.present? ? Organization.first.id : create(:organization).id}
    user_id {User.first.present? ? User.first.id : create(:user).id}
    amount 300

    factory :stripe_donation do
      is_paid true
      is_subscription true
      factory :unpaid_stripe_donation do
        is_paid false
        is_subscription false
      end
      amount 10000
      user_id {create(:stripe_user).id}
    end
  end
end
