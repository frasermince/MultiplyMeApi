require 'rails_helper'

RSpec.configure do |c|
  c.include DonationCreator
  c.include DonationAmounts
end

#uses donation as the model that uses traversable
#currently this is the only model that uses it
RSpec.describe Traversable do
  describe 'creating a donation' do
    it 'calculates the amount and count of one child' do
      create_one_child
      expect_parent_downline_to_equal 1, child_amount
    end

    it 'calculates even among multiple levels' do
      create_grandchild
      expect_parent_downline_to_equal 2, grandchild_amount + child_amount
      expect_child_downline_to_equal 1, grandchild_amount
    end

    #add second grandchild
    it 'calculates with multiple children per level' do
      create_second_grandchild
      expect_parent_downline_to_equal 3, child_amount + grandchild_amount + second_grandchild_amount
      expect_child_downline_to_equal 2, grandchild_amount + second_grandchild_amount
    end
  end

  describe 'updating a donation' do
    it 'calculates the amount and count of one child' do
      create_and_update_one_child
      expect_parent_downline_to_equal 1, updated_child_amount
    end

    it 'calculates even among multiple levels' do
      create_and_update_grandchild
      expect_parent_downline_to_equal 2, child_amount + updated_grandchild_amount
      expect_child_downline_to_equal 1, updated_grandchild_amount
    end

    it 'calculates with multiple children per level' do
      create_and_update_second_grandchild
      expect_parent_downline_to_equal 3, child_amount + grandchild_amount + updated_second_grandchild_amount
      expect_child_downline_to_equal 2, grandchild_amount + updated_second_grandchild_amount
    end

  end

  describe 'destroying a donation' do
    it 'calculates the amount and count of one child' do
      create_one_child
      @child_donation.destroy
      expect_parent_downline_to_equal 0, 0
    end

    it 'calculate even among multiple levels' do
      create_grandchild
      @grandchild_donation.destroy
      expect_parent_downline_to_equal 1, child_amount
      expect_child_downline_to_equal 0, 0
    end

    it 'calculates with multiple children per level' do
      create_second_grandchild
      @second_grandchild_donation.destroy
      expect_parent_downline_to_equal 2, child_amount + grandchild_amount
      expect_child_downline_to_equal 1, grandchild_amount
    end

  end

  describe '#one_grandchild' do
    context 'there is one grandchild' do
      it 'returns true' do
        create_grandchild
        expect(@parent_donation.one_grandchild).to eq(true)
      end
    end
    context 'there is more than one grandchild' do
      it 'returns false' do
        create_second_grandchild
        expect(@parent_donation.one_grandchild).to eq(false)
      end
    end
  end

  def expect_child_downline_to_equal(count, amount)
    donation = Donation.find attributes_for(:child)[:id]
    expect(donation.downline_count).to eq(count)
    expect(donation.downline_amount).to eq(amount)
  end

  def expect_parent_downline_to_equal(count, amount)
    donation = Donation.find attributes_for(:parent)[:id]
    expect(donation.downline_count).to eq(count)
    expect(donation.downline_amount).to eq(amount)
  end
end
