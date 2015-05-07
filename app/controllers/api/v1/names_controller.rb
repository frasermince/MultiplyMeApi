module Api
  module V1
    class NamesController < ApplicationController
      def show
        user = Donation.find(params[:id]).user
        render json: {name: user.name}
      end
    end
  end
end
