module Api
  module V1
    class OrganizationsController < BaseController
      def show
        @organization = Organization.select('name, campaign_end_date, id').find params[:id]
        render json: {organization: @organization}, status: :ok, methods: [:donation_count, :donation_amount]
      end
    end
  end
end
