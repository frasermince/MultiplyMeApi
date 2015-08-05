module Api
  module V1
    class DonationsController < BaseController
      before_action :authenticate_user!, except: [:show]
      def create
        @donation = Donation.new donation_params
        donation_decorator = DonationDecorator.new(@donation, card_params, current_user, params[:subscribe], params[:referral_code])
        respond_to_create donation_decorator
      end

      def show
        @donation = Donation.find params[:id]
        parent_name = @donation.parent ? @donation.parent.user.name : nil
        parents_children_count = @donation.parent ? @donation.parent.children.count : nil
        parent_time_remaining = @donation.parent ? @donation.parent.time_remaining : nil
        render json: {donation: @donation, name: @donation.user.name, parent_donation: @donation.parent, parent_name: parent_name, parents_children_count: parents_children_count, parent_time_remaining: parent_time_remaining}, status: :ok
      end

      def update
        @donation = Donation.find params[:id]
        return render(json: {error:"Unauthorized" }, status: :unauthorized) unless @donation.is_owner? current_user.id
        if @donation.update donation_params
          render json: {donation: @donation}, status: :ok
        else
          render json: @donation.errors, status: :unprocessable_entity
        end
      end

      private

      def respond_to_create(donation_decorator)
        begin
          donation_decorator.save!
        rescue Stripe::StripeError => error
          return render json: {error: error.message}, status: :unprocessable_entity
        end
        render json: {donation: donation_decorator.donation}, status: :created
      end

      def donation_params
        params.require(:donation).permit(:parent_id, :amount, :organization_id, :is_default, :is_subscription, :is_challenged)
      end

      def card_params
        params.require(:card).require(:email)
        params.require(:card).require(:token)
        params.require(:card).permit(:email, :token)
      end

    end
  end
end
