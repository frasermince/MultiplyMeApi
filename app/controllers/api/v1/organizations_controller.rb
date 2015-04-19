module Api
  module V1
    class OrganizationsController < ApplicationController
      def show
        @organization = Organization.find params[:id]
        render json: {organization: @organization}, status: :ok
      end
    end
  end
end
