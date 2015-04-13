require "stripe"
class User < ActiveRecord::Base
  devise :database_authenticatable, :recoverable,
    :trackable, :validatable, :registerable,
    :omniauthable

  include GravatarImageTag
  include DeviseTokenAuth::Concerns::User
  has_many :donations
  has_many :organizations_user
  has_many :organizations, through: :organizations_user
  before_create :skip_confirmation!

  def save_stripe_user(params)
    self.stripe_id = self.create_stripe_user params
    self.save
  end

  def get_gravatar_url
    gravatar_image_url(self.email, filetype: :png, secure: true, size: 100)
  end

  def create_stripe_user(params)
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    customer = Stripe::Customer.create(
      {
        source: params[:token],
        email: params[:email]
      }
    )
    return customer.id
  end

  def create_credit_card(token)
    customer = Stripe::Customer.retrieve(self.stripe_id)
    customer.sources.create(:source => token)
  end

  def add_credit_card(token)
    if self.stripe_id.present?
      self.create_credit_card token
      true
    else
      false
    end
  end

  def add_to_impact(donation)
    unless donation.user_cycles?
      self.network_impact += donation.downline_amount
    end
    self.personal_impact += donation.yearly_amount
      self.save
  end

  def add_to_recurring(donation)
    if donation.is_subscription
      self.recurring_amount += donation.amount
    end
  end
end
