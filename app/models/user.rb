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
      total = donation.children.reduce(donation.yearly_amount) do |child_accumulator, child|
        if child.user == self
          child_accumulator
        else
          child_accumulator + child.yearly_amount
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

  def authentication_keys
    [:email]
  end

  def get_gravatar_url
    gravatar_image_url(self.email, filetype: :png, secure: true, size: 100)
  end
end
