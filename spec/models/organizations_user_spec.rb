require 'rails_helper'

RSpec.describe OrganizationsUser, :type => :model do

  it { should belong_to(:organization) }
  it { should belong_to(:user) }

  describe '#find_or_create' do
    context 'OrganizationsUser for user_id and organization_id already exists' do
      it 'returns that OrganizationsUser' do
        organizations_user = create(:organizations_user)
        result = OrganizationsUser.find_or_create(organizations_user.organization_id, organizations_user.user_id)

        expect(result).to eq(organizations_user)
      end
    end
    context 'keys do not exist' do
      it 'creates a new record' do
        user = create(:user)
        organization = create(:organization)
        result = OrganizationsUser.find_or_create(organization.id, user.id)
        expect(result.organization).to eq(organization)
        expect(result.user).to eq(user)
      end
    end

  end
end
