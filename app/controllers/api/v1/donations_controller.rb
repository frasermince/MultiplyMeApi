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

      def show
        @donation = Donation.find params[:id]
        render json: {donation: @donation}, status: :ok
      end

      def update
        @donation = Donation.find params[:id]
        if @donation.update donation_params
          render json: {donation: @donation}, status: :ok
        else
          render json: @donation.errors, status: :unprocessable_entity
        end
      end

      private

      def donation_params
        params.require(:donation).permit(:parent_id, :amount, :user_id, :organization_id)
      end

    end
  end
end
