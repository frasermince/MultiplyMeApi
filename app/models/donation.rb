# Donation is used to track donations created by the user
# Includes two concerns
class Donation < ActiveRecord::Base
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
end
