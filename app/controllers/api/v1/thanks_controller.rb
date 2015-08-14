module Api
  module V1
    class ThanksController < BaseController
      def create
        content = params[:content]
        friend_name = params[:friend_name]
        user = Donation.find(params[:id]).user
        NotificationMailer.thank_friend(user, friend_name, content)
      end
    end
  end
end
