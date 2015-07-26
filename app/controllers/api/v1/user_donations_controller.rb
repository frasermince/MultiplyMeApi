module Api
  module V1
    class UserDonationsController < BaseController
      def show
        user = User.find(params[:id])
        donations = user.donations.filter_by_organization params[:organization_id]
        render json: {donation_ids: donations.map{|donation| donation.id}}, status: :ok
      end
    end
  end
end
