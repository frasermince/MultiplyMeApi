require 'rails_helper'

RSpec.describe CompletedChallengePolicy do
  describe '#challenge_completed?' do
    context 'has three children and can_still_complete? is true' do
      it 'returns true' do
        donation = create(:donation)
        completed_challenge_policy = CompletedChallengePolicy.new donation

        allow(donation.children).to receive(:count).and_return(3)
        allow(completed_challenge_policy)
          .to receive(:can_still_complete?)
          .and_return(true)

        expect(completed_challenge_policy.challenge_completed?).to be_truthy
      end
    end

    context 'can_still_complete? is false' do
      it 'returns false' do
        donation = create(:donation)
        completed_challenge_policy = CompletedChallengePolicy.new donation
        allow(donation.children).to receive(:count).and_return(3)
        allow(completed_challenge_policy)
          .to receive(:can_still_complete?)
          .and_return(false)
        expect(completed_challenge_policy.challenge_completed?).to be_falsey
      end
    end

    context 'has less than three children' do
      it 'returns false' do
        donation = create(:donation)
        completed_challenge_policy = CompletedChallengePolicy.new donation
        allow(donation.children).to receive(:count).and_return(2)
        allow(completed_challenge_policy)
          .to receive(:can_still_complete?)
          .and_return(false)

        expect(completed_challenge_policy.challenge_completed?).to be_falsey
      end
    end
  end
end
