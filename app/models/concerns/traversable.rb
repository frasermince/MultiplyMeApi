require 'set'
module Traversable
  extend ActiveSupport::Concern

  included do
    belongs_to :parent, :class_name => 'Donation'
    has_many :children, :class_name => 'Donation', :foreign_key => 'parent_id'
  end

  def traverse_downline(set)
    set.add self.id
    self.children.each do |child|
      set = set | child.traverse_downline(set)
    end
    set
  end

  def one_grandchild
    grandchildren = 0
    self.children.each do |child|
      grandchildren += child.children.count
    end
    grandchildren == 1
  end
end
