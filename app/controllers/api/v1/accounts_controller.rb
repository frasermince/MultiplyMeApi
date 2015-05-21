module Api
  module V1
    class AccountsController < ApplicationController
      def show
        user = User.find params[:id]
        personal_impact = user.personal_impact
        network_impact = user.network_impact
        render json: {personal_impact: personal_impact,
                      network_impact: network_impact,
                      total_impact: personal_impact + network_impact,
                      recurring_amount: user.recurring_amount,
                      only_recurring: user.only_recurring,
                      all_cancelled: user.all_cancelled?
        }, status: :ok
      end
    end
  end
end
