# Donation is used to track donations created by the user
# Includes two concerns
class Donation < ActiveRecord::Base

  before_create :set_referral
  # tracks a user's downline
  include Traversable
  # tracks the amount of money donated
  # automatically charges for a donation when it has three children
  belongs_to :user
  belongs_to :organization
  # amount is a integer in cents
  validates :amount, :downline_count, :downline_amount,
    :organization_id, :user_id, presence: true

  def set_referral
    self.referral_code = ReferralCodeService.new(self).generate_code
  end

  def is_owner?(user_id)
    self.user_id == user_id
  end

  def time_remaining
    (((self.created_at + 3.days) - DateTime.now) / 3600 / 24).to_i
  end

  def yearly_amount
    if self.is_subscription && self.is_cancelled && self.cancelled_time.present?
      months = ((self.cancelled_time.to_f - self.created_at.to_f) / (3600 * 24 * 30)).ceil
      self.amount * months
    else
      yearly = self.amount
      if self.is_subscription
        yearly *= 12
      end
      yearly
    end
  end

  def user_cycles?
    if self.parent.nil?
      false
    else
      !(self.parent.find_cycle self.user).nil?
    end
  end

  def find_cycle user
    if self.user == user
      self
    elsif self.parent.nil?
      nil
    else
      self.parent.find_cycle user
    end
  end

  def subscription_length(starting_timestamp)
    if self.is_subscription
      today = Time.now
      (today.year * 12 + today.month) - (starting_timestamp.year * 12 + starting_timestamp.month)
    else
      0
    end
  end

  def delete_subscription
    if self.is_subscription && self.is_paid
      customer = self.organization.get_stripe_user self.user
      subscriptions = customer.subscriptions
      unless subscriptions.data.empty?
        result = subscriptions.retrieve(self.stripe_id)
        self.update_attribute('is_cancelled', true)
        self.update_attribute('cancelled_time', DateTime.now)
        result.delete
      end
    end
  end
end
