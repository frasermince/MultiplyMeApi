module Api
  module V1
    class DonationRemindersController < BaseController
      def create
        donation = Donation.find params[:id]
        if reminder_valid(donation)
          donation.update_attribute('last_reminder', DateTime.now)
          NotificationMailer.remind_friend(donation.user, donation, donation.organization_id).deliver_now
        end
      end

      private
      def reminder_valid(donation)
        (donation.last_reminder.nil? ||
         donation.last_reminder < 12.hours.ago) &&
        donation.is_challenged &&
        !donation.is_paid
      end

    end
  end
end
