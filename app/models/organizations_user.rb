class OrganizationsUser < ActiveRecord::Base
  belongs_to :organization
  belongs_to :user
  def self.find_or_create(organization_id, user_id)
    query_hash = {organization_id: organization_id, user_id: user_id}
    organizations_user = self.where(query_hash).first
    organizations_user ||= self.create(query_hash)
  end

  def get_stripe_user
    if self.stripe_id.present?
      Stripe.api_key = self.organization.stripe_access_token
      Stripe::Customer.retrieve self.stripe_id
    else
      create_stripe_user
    end
  end

  def create_stripe_user
    Stripe.api_key = self.organization.stripe_access_token
    token_id = create_stripe_token(self.user.stripe_id)
    customer = Stripe::Customer.create(
      *stripe_user_params(token_id)
    )
    save_stripe_user(customer)
  end

  def create_stripe_token(customer_id)
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    token = Stripe::Token.create(
      { customer: customer_id},
      self.organization.stripe_access_token
    )
    token.id
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
