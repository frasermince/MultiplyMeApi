module Api
  module V1
    class DonationsController < ApplicationController

      def create
        @donation = Donation.new donation_params
        if @donation.save
          render json: {donation: @donation}, status: :created
        else
          render json: @donation.errors, status: :unprocessable_entity
        end
      end

      private

      def donation_params
        params.require(:donation).permit(:parent_id, :amount)
      end

    end
  end
end
