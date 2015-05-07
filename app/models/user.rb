require 'stripe'
require 'mailchimp'
require 'set'
class User < ActiveRecord::Base

  devise :database_authenticatable, :recoverable,
    :trackable, :validatable, :registerable,
    :omniauthable

  include GravatarImageTag
  include DeviseTokenAuth::Concerns::User
  has_many :donations
  has_many :organizations_user
  has_many :organizations, through: :organizations_user

  def personal_impact
    total = 0
    self.donations.where(is_paid: 1).each{|donation| total += donation.yearly_amount }
    total
  end

  def network_impact
    network_set = Set.new
    self.donations.each do |donation|
      network_set = network_set | donation.traverse_downline(network_set)
    end
    network_set.subtract self.donations.map{|donation| donation.id}
    total = 0
    network_set.each do |id|
      donation = Donation.find(id)
      if donation.is_paid
        total += donation.yearly_amount
      end
    end
    total
  end

  def only_recurring
    self.donations.where(is_paid: true).each do |donation|
      return false unless donation.is_subscription
    end
    true
  end

  def recurring_amount
    Donation.where(user_id: self.id, is_paid: true, is_subscription: true).sum(:amount)
  end

  def save_stripe_user(params)
    self.stripe_id = self.create_stripe_user params
    self.save
  end

  def mailing_subscribe(list_id)
    @mailchimp = Mailchimp::API.new Rails.application.secrets.mailchimp_api_key
    email = self.email
    begin
      @mailchimp.lists.subscribe(list_id , {'email' => email})
    rescue Mailchimp::Error => ex
      puts "***EX #{ex}"
      if ex.message
        msg = ex.message
      else
        msg = "An unknown error occurred"
      end
      return {status: false, message: msg}
    end
    {status: true}
  end

  def authentication_keys
    [:email]
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
