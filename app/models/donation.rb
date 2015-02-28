class Donation < ActiveRecord::Base
  include Traversable
  # tracks a user's downline
  include Pledgeable
  #tracks the amount of monay donated
  belongs_to :user
  belongs_to :organization
  validates :amount, :downline_count, :downline_amount,
            :organization_id, :user_id, presence: true
  # amount is a integer in cents
end
