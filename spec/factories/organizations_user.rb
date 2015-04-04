FactoryGirl.define do
  factory :organizations_user do
    user_id {User.first ? User.first.id : create(:user).id}
    organization_id {Organization.first ? Organization.first.id : create(:organization).id}
  end
end
