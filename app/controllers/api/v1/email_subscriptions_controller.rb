module Api
  module V1
    class EmailSubscriptionsController < BaseController
      before_action :authenticate_user!
      def create
        current_user.update_attribute('is_subscribed', true)
        render json: {}, status: :ok
      end
      def destroy
        current_user.update_attribute('is_subscribed', false)
        render json: {}, status: :ok
      end
    end
  end
end
