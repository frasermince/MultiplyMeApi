class OrganizationsUser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user

  def self.get_stripe_user(organization, user)
    organization_user = find_or_create(organization.id, user.id)
    organization_user.get_stripe_user
  end

  def self.find_or_create(organization_id, user_id)
    query_hash = {organization_id: organization_id, user_id: user_id}
    organizations_user = self.where(query_hash).first
    organizations_user ||= self.create(query_hash)
  end

  def get_stripe_user
    if self.stripe_id.present?
      stripe_client = StripeClient.new self.organization
      stripe_client.retrieve_stripe_user self
    else
      create_stripe_user
    end
  end

  def create_stripe_user
    stripe_client = StripeClient.new(self.organization)
    token_id = stripe_client.create_stripe_token(self.user.stripe_id)
    customer = stripe_client.create_stripe_user(token: token_id, email: self.user.email)
    save_stripe_user(customer)
  end

  private

  def save_stripe_user(customer)
    self.stripe_id = customer.id
    self.save
    customer
  end

  def stripe_user_params(token_id)
    [{
        source: token_id,
        email: self.user.email
    }, self.organization.stripe_access_token]
  end

end
