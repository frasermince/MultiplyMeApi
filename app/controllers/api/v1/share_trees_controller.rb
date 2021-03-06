module Api
  module V1
    class ShareTreesController < BaseController
      def show
        @donation = ReferralCodeService.find_donation_by_code params[:id]
        @organization_id = params[:organization_id]
        render(json: share_tree_json, status: :ok)
      end

      private
      def share_tree_json
        {
          hours_remaining: (72.hours - (DateTime.now.to_f - @donation.created_at.to_f)) / 3600,
          personal_impact: @donation.user.personal_impact(@organization_id),
          network_impact: @donation.user.network_impact(@organization_id),
          parent: parent,
          children: children,
          number_of_children: @donation.children.count,
          paid: @donation.is_paid,
          referral_code: @donation.referral_code
        }
      end

      def parent
        {
          donation: @donation,
          name: @donation.user.name,
          image_url: @donation.user.get_gravatar_url
        }
      end

      def children
        @donation.children.limit(3).map do |child|
          {donation: child,
           name: child.user.name,
           image_url: child.user.get_gravatar_url(100)
          }
        end
      end
    end
  end
end
