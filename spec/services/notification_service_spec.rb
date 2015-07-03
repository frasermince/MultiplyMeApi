require 'rails_helper'

RSpec.configure do |c|
  c.include DonationCreator
  c.include DonationAmounts
end

RSpec.describe NotificationService do
  describe '#send_mail' do
    context 'self.is_challenged is true' do
      it 'sends a pledged email' do
        donation = build_stubbed(:donation)
        notification_service = NotificationService.new donation
        mailing_stubs false, false, false
        expect {notification_service.send_mail}
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
    context 'self.is_challenged is false' do
      it 'sends a donation email' do
        donation = build_stubbed(:donation)
        donation.is_challenged = false
        notification_service = NotificationService.new donation
        mailing_stubs false, false, false
        expect {notification_service.send_mail}
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
    context 'self.one_grandchild is true' do
      it 'sends a first_grandchild email' do
        mailing_stubs true, false, false
        donation = build_stubbed(:donation)
        child_donation = build_stubbed(:donation)
        child_donation.parent_id = donation.id
        grandchild_donation = build_stubbed(:donation)
        grandchild_donation.parent_id = child_donation.id
        notification_service = NotificationService.new grandchild_donation
        expect {notification_service.send_mail}
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
    context 'can_still_complete? is true' do
      it 'sends a completion email' do
        mailing_stubs false, true, true
        parent_donation = create(:donation)
        child_donation = create(:donation)
        child_donation.parent_id = parent_donation.id
        notification_service = NotificationService.new child_donation
        expect {notification_service.send_mail}
          .to change { ActionMailer::Base.deliveries.count }.by(2)
      end
    end
    context 'can_still_complete? is true' do
      context 'and there is one child' do
        it 'sends a first friend email' do
          mailing_stubs false, false, true
          parent_donation = create(:donation)
          child_donation = create(:donation)
          child_donation.parent_id = parent_donation.id

          notification_service = NotificationService.new child_donation
          expect {notification_service.send_mail}
            .to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end
      context 'and there are two children' do
        it 'sends a first friend email' do
          mailing_stubs false, false, true
          parent_donation = create(:donation)
          child_donation = create(:donation)
          child_donation.parent_id = parent_donation.id
          second_child_donation = create(:donation)
          second_child_donation.parent_id = parent_donation.id

          notification_service = NotificationService.new second_child_donation
          expect {notification_service.send_mail}
            .to change { ActionMailer::Base.deliveries.count }.by(1)
        end
      end
    end
  end
  def mailing_stubs(grandchild, completed, can_complete)
    allow_any_instance_of(Donation)
      .to receive(:one_grandchild)
      .and_return(grandchild)
    allow_any_instance_of(CompletedChallengePolicy)
      .to receive(:challenge_completed?)
      .and_return(completed)
    allow_any_instance_of(CompletedChallengePolicy)
      .to receive(:can_still_complete?)
      .and_return(can_complete)
  end
end
