require 'rails_helper'


RSpec.configure do |c|
  c.include DonationCreator
end

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
      other_user_donation = create(:first_new_user_donation)
      create_two_children
      allow_any_instance_of(User)
        .to receive(:donations)
        .and_return([@parent_donation, @child_donation, @second_child])
      expect(@user.direct_impact).to eq(@parent_donation.yearly_amount + @child_donation.yearly_amount + @second_child.yearly_amount + other_user_donation.yearly_amount)
    end
  end

  describe '#all_cancelled?' do
    context' when all are cancelled' do
      it 'returns true' do
        create_two_children
        allow_any_instance_of(User)
          .to receive(:donations)
          .and_return([@parent_donation, @child_donation, @second_child])
        allow_any_instance_of(Donation)
          .to receive(:is_cancelled)
          .and_return(true)
        expect(@user.all_cancelled?).to eq(true)
      end
    end
    context 'when they are not cancelled' do
      it 'returns false' do
        create_two_children
        allow_any_instance_of(User)
          .to receive(:donations)
          .and_return([@parent_donation, @child_donation, @second_child])
        allow_any_instance_of(Donation)
          .to receive(:is_cancelled)
          .and_return(false)
        expect(@user.all_cancelled?).to eq(false)
      end
    end
  end
end
