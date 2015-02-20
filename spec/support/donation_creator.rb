module DonationCreator
  def create_parent(is_challenged=true)
    @parent_donation = is_challenged ? create(:parent) : create(:unchallenged_donation)
  end

  def create_one_child
    create_parent
    @child_donation = create(:child)
  end

  def create_and_update_one_child
    create_one_child
    @child_donation.update(attributes_for(:updated_child))
  end

  def create_three_children(is_paid = false)
    if is_paid
      @parent_donation = create(:paid_donation)
    else
      create_one_child
    end
    create(:second_child)
    create(:third_child)
  end

  def create_grandchild
    create_one_child
    @grandchild_donation = create(:grandchild)
  end

  def create_and_update_grandchild
    create_grandchild
    @grandchild_donation.update(attributes_for(:updated_grandchild))
  end

  def create_second_grandchild
    create_grandchild
    @second_grandchild_donation = create(:second_grandchild)
  end

  def create_and_update_second_grandchild
    create_second_grandchild
    @second_grandchild_donation.update(attributes_for(:updated_second_grandchild))
  end
end
