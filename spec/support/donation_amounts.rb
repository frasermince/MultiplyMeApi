module DonationAmounts
  def child_amount
    attributes_for(:child)[:amount]
  end

  def updated_child_amount
    attributes_for(:updated_child)[:amount]
  end

  def grandchild_amount
    attributes_for(:grandchild)[:amount]
  end

  def updated_grandchild_amount
    attributes_for(:updated_grandchild)[:amount]
  end

  def second_grandchild_amount
    attributes_for(:second_grandchild)[:amount]
  end

  def updated_second_grandchild_amount
    attributes_for(:updated_second_grandchild)[:amount]
  end
end
