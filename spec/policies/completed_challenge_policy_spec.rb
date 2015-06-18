require 'rails_helper'

RSpec.configure do |c|
  c.include DonationCreator
  c.include DonationAmounts
end

RSpec.describe CompletedChallengePolicy do
  describe '#challenge_completed?' do
    context 'has three children and is less than three days old' do
      it 'returns true' do
        allow_any_instance_of(PaymentService)
          .to receive(:purchase)
          .and_return(true)
        create_three_children
        completed_challenge_policy = CompletedChallengePolicy.new @parent_donation
        expect(completed_challenge_policy.challenge_completed?).to be_truthy
      end
    end

    context 'is more than three days old' do
      it 'returns false' do
        allow_any_instance_of(PaymentService)
          .to receive(:purchase)
          .and_return(true)
        create_three_children true
        completed_challenge_policy = CompletedChallengePolicy.new @third_child
        expect(completed_challenge_policy.challenge_completed?).to be_falsey
      end
    end

    context 'has less than three children' do
      it 'returns false' do
        allow_any_instance_of(PaymentService)
          .to receive(:purchase)
          .and_return(true)
        create_two_children
        completed_challenge_policy = CompletedChallengePolicy.new @second_child
        expect(completed_challenge_policy.challenge_completed?).to be_falsey
      end
    end
  end
end
