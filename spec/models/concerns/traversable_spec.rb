require 'rails_helper'

#uses donation as the model that uses traversable
#currently this is the only model that uses it
RSpec.describe Traversable do

  describe '#one_grandchild' do
    context 'there is one grandchild' do
      it 'returns true' do
        donation = create(:donation)
        child_donation = create(:donation)
        child_donation.update_attribute('parent_id', donation.id)
        grandchild_donation = create(:donation)
        grandchild_donation.update_attribute('parent_id', child_donation.id)
        expect(donation.one_grandchild).to eq(true)
      end
    end
    context 'there is not one grandchild' do
      it 'returns false' do
        donation = create(:donation)
        expect(donation.one_grandchild).to eq(false)
      end
    end
  end
end
