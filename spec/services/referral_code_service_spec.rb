require 'rails_helper'

RSpec.describe ReferralCodeService do
  describe '#generate_code' do
    it 'generates a code' do
      donation = create(:parent)
      referral_code_service = ReferralCodeService.new donation
      referral_code_service.generate_code
      expect(donation.reload.referral_code).to eq(donation.user.name + donation.id.to_s )
    end
  end

  describe '#find_donation_by_code' do
    it 'finds based on a given code' do
      create(:referral_donation)
      expect(ReferralCodeService.find_donation_by_code('FraserMince97')).to be
    end
  end

  describe '#find_id_by_code' do
    it 'finds an id based on a given code' do
      create(:referral_donation)
      expect(ReferralCodeService.find_id_by_code('FraserMince97')).to be
    end
  end
end
