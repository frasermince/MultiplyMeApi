module Api
  module V1
    class ThanksController < BaseController
      def create
        content = params[:content]
        user = Donation.find(params[:id]).user
        NotificationMailer.thank_friend(user, content)
      end
    end
  end
end
