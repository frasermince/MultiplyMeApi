module DonationAmounts
  def child_amount
    build(:child).yearly_amount
  end

  def updated_child_amount
    build(:updated_child).yearly_amount
  end

  def grandchild_amount
    build(:grandchild).yearly_amount
  end

  def updated_grandchild_amount
    build(:updated_grandchild).yearly_amount
  end

  def second_grandchild_amount
    build(:second_grandchild).yearly_amount
  end

  def updated_second_grandchild_amount
    build(:updated_second_grandchild).yearly_amount
  end
end
