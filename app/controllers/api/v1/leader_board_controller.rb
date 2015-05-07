module Api
  module V1
    class LeaderBoardController < ApplicationController

      def index
        limit = params[:limit].nil? ? 10 : params[:limit]
        @leaders = get_leaders limit
        render json: {leaders: @leaders}, status: :ok
      end

      private

      def get_leaders limit
        User.order('personal_impact + network_impact DESC')
          .limit(limit)
          .select(:id, 'users.name as name', 'users.email as email', 'personal_impact + network_impact as contribution')
      end

    end
  end
end
