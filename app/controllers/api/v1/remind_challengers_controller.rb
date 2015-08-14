module Api
  module V1
    class RemindChallengersController < BaseController

      def index
        organization_id = params[:organization_id]
        donations = Donation.where(organization_id: organization_id, is_challenged: true, is_paid: false)
        donations = donations.select{ |donation| donation.hours_remaining < 24 && donation.hours_remaining > 0 }
        remind_all(donations, organization_id)
      end

      private
      def remind_all(donations, organization_id)
        donations.each do |donation|
          if ReminderPolicy.new(donation).reminder_valid
            NotificationMailer.remind_friend(donation.user, donation, organization_id).deliver_now
          end
        end
      end

    end
  end
end
