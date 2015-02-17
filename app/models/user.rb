class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
  has_many :donations

  def save_stripe_user(email, token, organization)
    self.stripe_id = self.create_stripe_user email, token, organization
    self.save
  end

  def create_stripe_user(email, token, organization)
    customer = Stripe::Customer.create(
      {
        card: token,
        email: email
      },
      organization.stripe_access_token
    )
    return customer.id
  end
end
