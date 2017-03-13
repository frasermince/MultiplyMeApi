require 'rails_helper'

RSpec.describe ReferralCodeService do
  describe '#generate_code' do
    it 'generates a code' do
      donation = create(:donation)
      referral_code_service = ReferralCodeService.new donation
      result = referral_code_service.generate_code
      expect(result).to eq(donation.user.name.split(" ")[0].downcase + donation.id.to_s )
    end
  end

  describe '#find_donation_by_code' do
    it 'finds based on a given code' do
      donation = build_stubbed(:donation)
      referral_code = 'frasermince97'
      allow(Donation).to receive(:where).with({referral_code: referral_code}).and_return([donation])
      expect(ReferralCodeService.find_donation_by_code(referral_code)).to be
    end
  end

  describe '#find_id_by_code' do
    it 'finds an id based on a given code' do
      donation = build_stubbed(:donation)
      referral_code = 'frasermince97'
      allow(Donation).to receive(:where).with({referral_code: referral_code}).and_return([donation])
      expect(ReferralCodeService.find_id_by_code(referral_code)).to be
    end
  end
end
