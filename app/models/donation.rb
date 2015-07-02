# Donation is used to track donations created by the user
# Includes two concerns
class Donation < ActiveRecord::Base

  before_create :set_referral
  # tracks a user's downline
  include Traversable
  # tracks the amount of money donated
  # automatically charges for a donation when it has three children
  include Pledgeable
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

end
