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
  attr_reader :contribution

  def all_cancelled?
    self.donations.each do |donation|
      if donation.is_subscription && !donation.is_cancelled
        return false
      end
    end
    true
  end

  def direct_impact
    self.donations.reduce(0) do |accumulator, donation|
      puts "***DONATION ID #{donation.id}"
      total = donation.children.reduce(donation.amount) do |child_accumulator, child|
        if child.user == self
          child_accumulator
        else
          puts "***CHILD ID #{child.id}"
          child_accumulator + child.amount
        end
      end
      total + accumulator
    end
  end

  def contribution
    personal_impact + network_impact
  end

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
    if self.stripe_id.present?
      result = self.add_credit_card(params[:token])
    else
      result = self.create_stripe_user params
      self.update_attribute('stripe_id', result[:id]) if result[:status] == :success
    end
    result
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
    begin
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    customer = Stripe::Customer.create(
      {
        source: params[:token],
        email: params[:email]
      }
    )
    rescue => error
      return {status: :failed, error: error}
    end
    return {status: :success, id: customer.id}
  end

  def create_credit_card(token)
    customer = Stripe::Customer.retrieve(self.stripe_id)
    customer.sources.create(:source => token)
  end

  def add_credit_card(token)
    begin
      Stripe.api_key = Rails.application.secrets.stripe_secret_key
      if self.stripe_id.present?
        self.create_credit_card token
        {status: :success}
      else
        {status: :failed, error: 'customer is not present'}
      end
    rescue => error
      return {status: :failed, error: error}
    end
  end

end
