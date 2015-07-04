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
    User.includes(:donations)
      .where('donations.organization_id = ? AND donations.is_paid = true', self.id)
      .references(:donations)
      .count
  end

  def donation_amount
    total = 0
    Donation.where(organization_id: self.id, is_paid: true)
      .each{|donation| total += donation.yearly_amount}
    total
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
