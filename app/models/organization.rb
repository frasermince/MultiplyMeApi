require 'rest_client'
# Stores information related to a specific nonprofit
# This includes authorization key to organization's stripe account
class Organization < ActiveRecord::Base
  has_many :donations
  has_many :organizations_user
  has_many :users, through: :organizations_user
  attr_reader :donation_count
  attr_reader :donation_amount

  def donation_count
    get_donations.count
  end

  def donation_amount
    total = 0
    self.get_donations.each{|donation| Rails.logger.warn"***HERE #{donation.yearly_amount}";total += donation.yearly_amount}
    total
  end

  def get_donations
    Donation.where(organization_id: self.id)
  end

  def get_stripe_user(user)
    organizations_user = OrganizationsUser.find_or_create self.id, user.id
    if organizations_user.stripe_id.present?
      Stripe.api_key = self.stripe_access_token
      Stripe::Customer.retrieve organizations_user.stripe_id
    else
      customer = create_stripe_user user.stripe_id, user.email
      organizations_user.stripe_id = customer.id
      organizations_user.save
      customer
    end
  end

  def create_stripe_user(customer_id, email)
    Stripe.api_key = self.stripe_access_token
    token_id = create_stripe_token(customer_id)
    customer = Stripe::Customer.create({
      source: token_id,
      email: email
    }, self.stripe_access_token)
    customer
  end

  def create_stripe_token(customer_id)
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    token = Stripe::Token.create(
      { customer: customer_id},
      self.stripe_access_token
    )
    token.id
  end

  def set_access_token(code)
      response = RestClient.post('https://connect.stripe.com/oauth/token', oauth_params(code))
      handle_response response
  end

  private
  def oauth_params(code)
    {
      client_secret: Rails.application.secrets.stripe_secret_key,
      code: code,
      grant_type: 'authorization_code',
      accept: :json,
      content_type: :json
    }
  end

  def handle_response(response)
    response = JSON.parse(response)
    self.stripe_access_token = response['access_token']
    self.stripe_id = response['stripe_user_id']
    self.save
  end
end
