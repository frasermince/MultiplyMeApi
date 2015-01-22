require 'rails_helper'

RSpec.describe Donation, :type => :model do

  it { should belong_to(:parent) }
  it { should have_many(:children) }

  describe 'creating a donation' do

    it 'calculates the amount and count of one child on save' do
      create_one_child
      expect_parent_downline_to_equal 1, 1
    end

    it 'calculates even among multiple levels' do
      create_grandchild
      expect_parent_downline_to_equal 2, 8.00
      expect_child_downline_to_equal 1, 7.00
    end

    #add second grandchild
    it 'calculates with multiple children per level' do
      create_second_grandchild
      expect_parent_downline_to_equal 3, 12.00
      expect_child_downline_to_equal 2, 11.00
    end

  end

  def expect_child_downline_to_equal(count, amount)
    expect(@child_donation.reload.downline_count).to eq(count)
    expect(@child_donation.reload.downline_amount).to eq(amount)
  end

  def create_parent
    @parent_donation = Donation.new(parent_id: nil, amount: 5, id: 1)
    @parent_donation.save
  end

  def create_one_child
    create_parent
    @child_donation = Donation.new(parent_id: 1, amount: 1, id: 2)
    @child_donation.save
  end

  def create_grandchild
    create_one_child
    @grandchild_donation = Donation.new(parent_id: 2, amount: 7.00, id:3)
    @grandchild_donation.save
  end

  def create_second_grandchild
    create_grandchild
    @second_grandchild_donation = Donation.new(parent_id: 2, amount: 4.00, id: 4)
    @second_grandchild_donation.save
  end

  def expect_parent_downline_to_equal(count, amount)
    expect(@parent_donation.reload.downline_count).to eq(count)
    expect(@parent_donation.reload.downline_amount).to eq(amount)
  end
end
