module Api
  module V1
    class ChallengedPledgesController < ApplicationController
      def index
        donations = Donation
          .where('created_at > ? AND is_challenged is true', 3.days.ago)
          .order('created_at DESC, amount')
        render json: {donations: donations.to_a}, status: :ok
      end
    end
  end
end
