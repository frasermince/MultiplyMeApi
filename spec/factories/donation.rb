FactoryGirl.define do
  factory :donation do
    organization_id {Organization.first.present? ? Organization.first.id : create(:organization).id}
    user_id {User.first.present? ? User.first.id : create(:user).id}
    amount 3

    factory :updated_donation do
      amount 4
    end

    factory :parent do
      amount 5
      id 1
      parent_id nil
      factory :unchallenged_donation do
        is_challenged false
      end
    end

    factory :child do
      amount 1
      id 2
      parent_id 1
      factory :updated_child do
        amount 5
      end
    end

    factory :grandchild do
      amount 7
      id 3
      parent_id 2
      factory :updated_grandchild do
        amount 6
      end
    end

    factory :second_grandchild do
      amount 4
      id 4
      parent_id 2
      factory :updated_second_grandchild do
        amount 5
      end
    end

    factory :second_child do
      amount 1
      id 5
      parent_id 1
    end

    factory :third_child do
      amount 1
      id 6
      parent_id 1
    end

  end
end
