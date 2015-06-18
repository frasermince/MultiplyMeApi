class CompletedChallengePolicy
  def initialize(donation)
    @donation = donation
  end

  def challenge_completed?
    @donation.children.count == 3 && self.can_still_complete?
  end

  def can_still_complete?
    @donation.is_challenged && @donation.created_at > 3.days.ago
  end
end
