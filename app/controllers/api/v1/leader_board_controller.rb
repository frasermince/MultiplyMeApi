module Api
  module V1
    class LeaderBoardController < ApplicationController

      def index
        limit = params[:limit].nil? ? 10 : params[:limit]
        @leaders = get_leaders limit
        render json: {leaders: @leaders}, status: :ok, methods: :contribution
      end

      private

      def get_leaders limit
        User.select(:id, 'users.name as name', 'users.email as email')
          .to_a
          .sort_by{|user| user.personal_impact(params[:organization_id]) + user.network_impact(params[:organization_id])}
          .reverse
          .first(limit.to_i)
      end
    end

  end
end
