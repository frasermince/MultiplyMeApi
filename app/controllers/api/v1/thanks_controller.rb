module Api
  module V1
    class ThanksController < BaseController
      def create
        content = params[:content]
        friend_name = params[:friend_name]
        user = ReferralCodeService.find_donation_by_code(params[:id]).user
        if user.thanks_date == nil || user.thanks_date < 1.day.ago
          NotificationMailer.thank_friend(user, friend_name, content).deliver_now
          user.update_attribute('thanks_date', DateTime.now)
        end
        render json: {}, status: :ok
      end
    end
  end
end
