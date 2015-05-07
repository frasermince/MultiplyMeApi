module Api
  module V1
    class UserDonationsController < ApplicationController
      def show
        user = User.find(params[:id])
        render json: {donation_ids: user.donations.map{|donation| donation.id}}, status: :ok
      end
    end
  end
end
