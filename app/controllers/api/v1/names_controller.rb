module Api
  module V1
    class NamesController < BaseController
      def show
        donation = Donation.find(params[:id])
        user = donation.user
        render json: {name: user.name, number_of_children: donation.children.count, is_paid: donation.is_paid}
      end
    end
  end
end
