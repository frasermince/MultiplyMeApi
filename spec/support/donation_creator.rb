module DonationCreator
  def create_parent(is_challenged=true)
    @parent_donation = is_challenged ? create(:parent) : create(:unchallenged_donation)
  end

  def create_paid
    @paid_donation = create(:paid_donation)
  end

  def create_one_child
    create_parent
    @child_donation = create(:child)
  end

  def create_and_update_one_child
    create_one_child
    @child_donation.update(attributes_for(:updated_child))
  end

  def create_two_children
    create_one_child
    @second_child = create(:second_child)
  end

  def create_three_children(old = false)
    create_two_children
    if old
      @parent_donation.created_at = 4.days.ago
      @parent_donation.save
    end
    create(:third_child)
  end

  def create_different_user_donations
    create_parent
    @first_child = create(:first_new_user_donation)
    @second_child = create(:second_new_user_donation)
    @third_child = create(:third_new_user_donation)
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
