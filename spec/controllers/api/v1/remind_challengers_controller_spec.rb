require 'rails_helper'

describe Api::V1::RemindChallengersController do
  describe '#index' do
    it 'sends an email for each challenge that has less than 24 hours left and is unpaid' do
      donation = create_unpaid_challenge 2.days.ago
      create_unpaid_challenge 2.days.ago
      create_unpaid_challenge 4.days.ago
      create_unpaid_challenge 1.day.ago
      expect{get :index, organization_id: donation.organization_id}
        .to change { ActionMailer::Base.deliveries.count }.by(2)
    end
  end
end

def create_unpaid_challenge(date)
  donation = create(:donation)
  donation.update_attribute('is_paid', false)
  donation.update_attribute('is_challenged', true)
  donation.update_attribute('created_at', date)
  donation
end
