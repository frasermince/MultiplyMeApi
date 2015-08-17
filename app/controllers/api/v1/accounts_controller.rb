module Api
  module V1
    class AccountsController < BaseController
      def show
        user = User.find params[:id]
        @organization_id = params[:organization_id]
        personal_impact = user.personal_impact @organization_id
        network_impact = user.network_impact @organization_id
        referral_code = user.donations.present? ? user.donations.last.referral_code : nil
        render json: json_response(user, personal_impact, network_impact, referral_code), status: :ok
      end
      private
      def children(user)
        donations = user.donations.where(organization_id: @organization_id)
        donations.inject([]) do |accumulator, donation|
          accumulator.concat donation.children.map{|child| {name: child.user.name, referral_link: child.referral_code, is_paid: child.is_paid, is_challenged: child.is_challenged, challenge_ongoing: child.hours_remaining > 0, can_thank: user.thanks_date.nil?}}
        end
      end
      def json_response(user, personal_impact, network_impact, referral_code)
        {
          personal_impact: personal_impact,
          network_impact: network_impact,
          total_impact: personal_impact + network_impact,
          recurring_amount: user.recurring_amount(@organization_id),
          only_recurring: user.only_recurring(@organization_id),
          all_cancelled: user.all_cancelled?(@organization_id),
          referral_code: referral_code,
          children: children(user)
        }
      end
    end
  end
end
