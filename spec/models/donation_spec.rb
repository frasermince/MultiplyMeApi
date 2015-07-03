require 'rails_helper'

RSpec.describe Donation, :type => :model do

  it { should belong_to(:organization) }
  it { should belong_to(:user) }
  it { should belong_to(:parent) }
  it { should have_many(:children) }

  describe 'donation factory' do
    it 'should be valid' do
      expect(create(:donation)).to be_valid
    end
  end
end
