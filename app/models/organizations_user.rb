class OrganizationsUser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  def self.find_or_create(organization_id, user_id)
    query_hash = {organization_id: organization_id, user_id: user_id}
    organizations_user = self.where(query_hash).first
    organizations_user ||= self.create(query_hash)
  end
end
