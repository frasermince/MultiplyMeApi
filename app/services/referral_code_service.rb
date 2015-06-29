class ReferralCodeService
  def initialize(donation)
    @donation = donation
  end

  def generate_code
    referral_code = @donation.user.name + @donation.id.to_s
    @donation.update_attribute('referral_code', referral_code)
  end

  def self.find_donation_by_code(code)
    if code.present?
      Donation.where(referral_code: code).first
    else
      nil
    end
  end

  def self.find_id_by_code(code)
    donation = find_donation_by_code code
    if donation.present?
      donation.id
    else
      nil
    end
  end
end
