module Api
  module V1
    class DonationRemindersController < BaseController

      def create
        donation = Donation.find params[:id]
        if ReminderPolicy.new(donation).reminder_valid
          NotificationMailer.remind_friend(donation.user, donation, donation.organization_id).deliver_now
        end
      end

    end
  end
end
