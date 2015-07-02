class ReferralCodeService
  def initialize(donation)
    @donation = donation
  end

  def generate_code
    @donation.user.name + @donation.id.to_s
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
