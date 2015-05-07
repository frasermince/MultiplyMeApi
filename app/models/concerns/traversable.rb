module Traversable
  extend ActiveSupport::Concern

  included do
    before_create :before_create
    before_update :before_amount_update, if: :amount_changed?
    before_update :before_paid_update, if: :is_paid_changed?
    before_destroy :before_destroy
    belongs_to :parent, :class_name => 'Donation'
    has_many :children, :class_name => 'Donation', :foreign_key => 'parent_id'
  end

  def before_create
    traverse_upline self.parent, 'create'
  end

  def before_destroy
    traverse_upline self.parent, 'destroy'
  end

  def before_amount_update
    if self.amount_was.present?
      traverse_upline self.parent, 'update'
    end
  end

  def before_paid_update
    traverse_upline self.parent, 'update impact'
  end

  def traverse_upline(donation, action)
    unless donation.nil?
      if self.amount_was.present? && self.is_subscription
        amount_was = self.amount_was * 12
      end
        donation.perform_update_action action, amount_was, self.yearly_amount
        traverse_upline donation.parent, action
    end
  end

  def perform_update_action(action, amount_was, amount)
    if action == 'create'
      add_downline_amount amount
    elsif action == 'update'
      replace_downline_amount amount_was, amount
    elsif action == 'destroy'
      reduce_downline amount
    elsif action == 'update impact'
      unless self.user_cycles?
        user = self.user
        user.network_impact += amount
        user.save
      end
    end
  end

  def add_downline_amount(amount)
    self.downline_amount += amount
    self.downline_count += 1
    self.save
  end

  def replace_downline_amount(old, new)
    self.downline_amount -= old
    self.downline_amount += new
    self.save
  end

  def reduce_downline(amount)
    self.downline_amount -= amount
    self.downline_count -= 1
    self.save
  end
end
