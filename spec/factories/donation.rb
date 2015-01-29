FactoryGirl.define do
  factory :donation do

    factory :parent do
      amount 5
      id 1
      parent_id nil
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

  end
end
