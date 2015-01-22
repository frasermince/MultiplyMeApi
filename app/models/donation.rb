class Donation < ActiveRecord::Base
  before_create :before_create
  belongs_to :parent, :class_name => 'Donation'
  has_many :children, :class_name => 'Donation', :foreign_key => 'parent_id'
  
  def before_create
    traverse_upline self.parent
  end
  
  def update_downline_amounts(downline_amount)
      self.downline_amount += downline_amount
      self.downline_count += 1
      self.save
  end

  def traverse_upline(donation)
    unless donation.nil?
      donation.update_downline_amounts self.amount
      traverse_upline donation.parent
    end
  end

end
