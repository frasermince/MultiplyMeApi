module Api
  module V1
    class NamesController < ApplicationController
      def show
        donation = Donation.find(params[:id])
        user = donation.user
        render json: {name: user.name, number_of_children: donation.children.count}
      end
    end
  end
end
