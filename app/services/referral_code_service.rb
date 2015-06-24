class ReferralCodeService
  def initialize(donation)
    @donation = donation
  end

  def generate_code
    referral_code = @donation.user.name + @donation.id.to_s
    @donation.update_attribute('referral_code', referral_code)
  end

  def self.find_by_code(code)
    Donation.where(referral_code: code).first
  end
end
