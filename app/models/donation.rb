class Donation < ActiveRecord::Base
  before_create :before_create
  before_update :before_update, if: :amount_changed?
  belongs_to :parent, :class_name => 'Donation'
  has_many :children, :class_name => 'Donation', :foreign_key => 'parent_id'
  
  def before_create
    traverse_upline self.parent, 'create'
  end

  def before_update
    traverse_upline self.parent, 'update'
  end

  def traverse_upline(donation, action)
    unless donation.nil?
      donation.perform_update_action action, self.amount_was, self.amount
      traverse_upline donation.parent, action
    end
  end

  def perform_update_action(action, amount_was, amount)
    if action == 'create'
      add_downline_amount amount
    elsif action == 'update'
      replace_downline_amount amount_was, amount
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
end
