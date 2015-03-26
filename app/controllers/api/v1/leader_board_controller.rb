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
        Donation.joins(:user).select(:id, 'users.name as name', 'users.email as email', 'amount + downline_amount as contribution').order('contribution DESC').limit(limit)
      end

    end
  end
end
