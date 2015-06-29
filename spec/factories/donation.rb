FactoryGirl.define do
  factory :donation do
    organization_id {Organization.first.present? ? Organization.first.id : create(:organization).id}
    user_id {User.first.present? ? User.first.id : create(:user).id}
    amount 300
    
    factory :referral_donation do
      referral_code 'FraserMince97'
    end
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

    factory :first_new_user_donation do
      id 6
      amount 1000
      user_id {create(:second_user).id}
      parent_id 1
      factory :second_new_user_donation do
        user_id {create(:third_user).id}
        id 3
        parent_id 6
      end
      factory :third_new_user_donation do
        user_id {create(:fourth_user).id}
        id 4
        parent_id 3
      end
    end

    factory :subscription_donation do
      is_subscription true
      factory :nonsubscription_donation do
        is_subscription false
      end
    end

    factory :updated_donation do
      amount 400
    end

    factory :parent do
      created_at DateTime.now
      amount 500
      id 1
      parent_id nil
      factory :old_donation do
        created_at 4.days.ago
      end
      factory :unchallenged_donation do
        is_challenged false
      end
      factory :paid_donation do
        is_paid true
      end
    end

    factory :child do
      amount 100
      id 2
      parent_id 1
      factory :updated_child do
        amount 500
      end
    end

    factory :grandchild do
      amount 700
      id 3
      parent_id 2
      factory :updated_grandchild do
        amount 600
      end
    end

    factory :second_grandchild do
      amount 400
      id 4
      parent_id 2
      factory :updated_second_grandchild do
        amount 500
      end
    end

    factory :second_child do
      amount 100
      id 5
      parent_id 1
    end

    factory :third_child do
      amount 100
      id 6
      parent_id 1
    end

  end
end
