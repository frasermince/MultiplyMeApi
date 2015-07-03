require 'rails_helper'

RSpec.describe User, :type => :model do
  before(:each) do
    @user = create(:user)
  end
  it { should have_many(:donations) }
  it { should have_many(:organizations).through(:organizations_user) }

  describe '#before_create' do
    it 'sets the referral' do
      donation = create(:donation)
      expect(donation.referral_code).to be
    end
  end

  describe '#direct_impact' do
    it 'returns the impact of users donations and children' do
      donation = create(:donation)
      other_user = create(:user)
      first_child = create(:donation)
      first_child.update_attribute('parent_id', donation.id)
      first_child.update_attribute('parent_id', other_user.id)

      second_child = create(:donation)
      second_child.update_attribute('parent_id', donation.id)

      allow_any_instance_of(User)
        .to receive(:donations)
        .and_return([donation, second_child])
      expect(@user.direct_impact).to eq(donation.yearly_amount + second_child.yearly_amount)
    end
  end

  describe '#all_cancelled?' do
    context' when all are cancelled' do
      it 'returns true' do
        donation = create(:donation)
        second_donation = create(:donation)
        allow_any_instance_of(User)
          .to receive(:donations)
          .and_return([donation, second_donation])
        allow_any_instance_of(Donation)
          .to receive(:is_cancelled)
          .and_return(true)
        expect(@user.all_cancelled?).to eq(true)
      end
    end
    context 'when they are not cancelled' do
      it 'returns false' do
        donation = create(:donation)
        second_donation = create(:donation)
        allow_any_instance_of(User)
          .to receive(:donations)
          .and_return([donation, second_donation])
        allow_any_instance_of(Donation)
          .to receive(:is_cancelled)
          .and_return(false)
        expect(@user.all_cancelled?).to eq(false)
      end
    end
  end
end
