class NotificationService
  def initialize(donation)
    @donation = donation
    @organization_id = donation.organization_id
  end

  def send_mail
    parent = @donation.parent
    if @donation.user.is_subscribed
      if @donation.is_challenged
        NotificationMailer.pledged(@donation.user, @donation).deliver_now
      else
        NotificationMailer.donated(@donation.user, @donation).deliver_now
      end
      if parent.present?
        grandparent = parent.parent
        if grandparent.present? && grandparent.one_grandchild
          NotificationMailer.first_grandchild(grandparent.user, grandparent, @organization_id).deliver_now
        end

        if CompletedChallengePolicy.new(parent).can_still_complete?
          if parent.children.count == 1
            NotificationMailer.first_friend(parent.user, parent, @donation.user, @organization_id).deliver_now
          elsif parent.children.count == 2
            NotificationMailer.second_friend(parent.user, parent, @donation.user, @organization_id).deliver_now
          end
        end

        if CompletedChallengePolicy.new(parent).challenge_completed?
          NotificationMailer.finish_challenge(parent.user, @donation.user, @organization_id).deliver_now
        end
      end
    end
    true
  end
end
