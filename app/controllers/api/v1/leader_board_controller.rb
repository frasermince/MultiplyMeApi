module Api
  module V1
    class LeaderBoardController < ApplicationController

      def index
        limit = params[:limit].nil? ? 10 : params[:limit]
        @leaders = get_leaders limit
        render json: {leaders: @leaders}, status: :ok, methods: :direct_impact
      end

      private

      def get_leaders limit
        User.select(:id, 'users.name as name', 'users.email as email')
          .to_a
          .sort_by{|user| user.direct_impact}
          .reverse
          .first(limit.to_i)
      end
    end

  end
end
