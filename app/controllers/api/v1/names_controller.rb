module Api
  module V1
    class NamesController < ApplicationController
      def show
        user = User.find params[:id]
        render json: {name: user.name}
      end
    end
  end
end
