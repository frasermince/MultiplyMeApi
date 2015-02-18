require "stripe"
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

  def create_credit_card(token)
    customer = Stripe::Customer.retrieve(self.stripe_id)
    customer.cards.create(:card => token)
  end

  def add_credit_card(token)
    if self.stripe_id.present?
      self.create_credit_card token
      true
    else
      false
    end
  end
end
