module Api
  module V1
    class UserSubscriptionsController < ApplicationController
      before_action :authenticate_user!
      def destroy
        current_user.donations.each do |donation|
          donation.destroy
        end
      end

    end
  end
end
