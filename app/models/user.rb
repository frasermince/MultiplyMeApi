require "stripe"
class User < ActiveRecord::Base
  include DeviseTokenAuth::Concerns::User
  has_many :donations

  def save_stripe_user(params)
    self.stripe_id = self.create_stripe_user params
    self.save
  end

  def create_stripe_user(params)
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    customer = Stripe::Customer.create(
      {
        card: params[:token],
        email: params[:email]
      }
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
