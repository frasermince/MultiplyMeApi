require 'rails_helper'

RSpec.describe Donation, :type => :model do

  it { should belong_to(:parent) }
  it { should have_many(:children) }

  describe 'creating a donation' do
    it 'calculates the amount and count of one child' do
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

  describe 'updating a donation' do
    it 'calculates the amount and count of one child' do
      create_and_update_one_child
      expect_parent_downline_to_equal 1, 5
    end

    it 'calculates even among multiple levels' do
      create_and_update_grandchild
      expect_parent_downline_to_equal 2, 7.00
      expect_child_downline_to_equal 1, 6.00
    end

    it 'calculates with multiple children per level' do
      create_and_update_second_grandchild
      expect_parent_downline_to_equal 3, 13
      expect_child_downline_to_equal 2, 12
    end

  end

  def expect_child_downline_to_equal(count, amount)
    expect(@child_donation.reload.downline_count).to eq(count)
    expect(@child_donation.reload.downline_amount).to eq(amount)
  end

  def expect_parent_downline_to_equal(count, amount)
    expect(@parent_donation.reload.downline_count).to eq(count)
    expect(@parent_donation.reload.downline_amount).to eq(amount)
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

  def create_and_update_one_child
    create_one_child
    @child_donation.update(amount: 5)
  end

  def create_grandchild
    create_one_child
    @grandchild_donation = Donation.new(parent_id: 2, amount: 7.00, id:3)
    @grandchild_donation.save
  end

  def create_and_update_grandchild
    create_grandchild
    @grandchild_donation.update(amount: 6.00)
  end

  def create_second_grandchild
    create_grandchild
    @second_grandchild_donation = Donation.new(parent_id: 2, amount: 4.00, id: 4)
    @second_grandchild_donation.save
  end

  def create_and_update_second_grandchild
    create_second_grandchild
    @second_grandchild_donation.update(amount: 5.00)
  end
end
