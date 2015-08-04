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
  before_save :default_values
  attr_reader :contribution

  def all_cancelled?(organization_id)
    filtered_donations = self.donations.filter_by_organization(organization_id)
    filtered_donations.each do |donation|
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

  def personal_impact(organization_id=2)
    filtered_donations = self.donations.filter_by_organization(organization_id)
    filtered_donations.where(is_paid: 1).reduce(0) do |accumulator, donation|
      accumulator += donation.yearly_amount
    end
  end

  def network_impact(organization_id=2)
    donations = self.donations.filter_by_organization(organization_id)
    network_set = donations.reduce(Set.new) do |accumulator, donation|
      accumulator | donation.traverse_downline(accumulator)
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

  def only_recurring(organization_id)
    donations = self.donations.filter_by_organization(organization_id)
    donations.where(is_paid: true).each do |donation|
      return false unless donation.is_subscription
    end
    true
  end

  def recurring_amount(organization_id)
    donations = self.donations.filter_by_organization(organization_id)
    donations.where(user_id: self.id, is_paid: true, is_subscription: true).sum(:amount)
  end

  def authentication_keys
    [:email]
  end

  def get_gravatar_url
    gravatar_image_url(self.email, filetype: :png, secure: true, size: 75)
  end

  private
  def default_values
    self.name ||= "anon"
  end
end
