require 'rails_helper'

RSpec.configure do |c|
  c.include DonationCreator
  c.include DonationAmounts
end

#uses donation as the model that uses traversable
#currently this is the only model that uses it
RSpec.describe Traversable do

  describe '#one_grandchild' do
    context 'there is one grandchild' do
      it 'returns true' do
        create_grandchild
        expect(@parent_donation.one_grandchild).to eq(true)
      end
    end
    context 'there is more than one grandchild' do
      it 'returns false' do
        create_second_grandchild
        expect(@parent_donation.one_grandchild).to eq(false)
      end
    end
  end
end
