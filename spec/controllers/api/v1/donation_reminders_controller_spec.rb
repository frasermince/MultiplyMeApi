require 'rails_helper'

describe Api::V1::DonationRemindersController do
  describe '#create' do
    context 'last reminder is newer than 12 hours ago' do
      it 'does not send email' do
        donation = create(:donation)
        donation.update_attribute('last_reminder', DateTime.now)
        expect{post :create, id: donation}
          .to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end

    context 'last reminder is older than 12 hours ago' do
      it 'does send email' do
        donation = create(:donation)
        donation.update_attribute('last_reminder', 13.hours.ago)
        expect{post :create, id: donation}
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context 'last reminder is nil' do
      it 'sends an email' do
        donation = create(:donation)
        expect{post :create, id: donation}
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
  end
end
