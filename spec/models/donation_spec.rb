require 'rails_helper'

RSpec.describe Donation, :type => :model do

  it { should belong_to(:organization) }
  it { should belong_to(:user) }
  it { should belong_to(:parent) }
  it { should have_many(:children) }

  describe 'factories' do
    it 'should be valid' do
      expect(create(:parent)).to be_valid
      expect(create(:child)).to be_valid
      expect(create(:grandchild)).to be_valid
      expect(create(:second_grandchild)).to be_valid
      expect(create(:second_child)).to be_valid
      expect(create(:third_child)).to be_valid

    end
  end
end
