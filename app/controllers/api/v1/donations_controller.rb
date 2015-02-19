module Api
  module V1
    class DonationsController < ApplicationController
      def create
        @donation = Donation.new donation_params
        @donation.user_id = current_user.id
        if @donation.save
          @donation.user.save_stripe_user(*card_params)
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
        params.require(:donation).permit(:parent_id, :amount, :organization_id, :is_default, :is_subscription, :is_challenged)
      end

      def card_params
        [params[:card][:email], params[:card][:token], @donation.organization]
      end

    end
  end
end
