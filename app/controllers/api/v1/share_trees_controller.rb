module Api
  module V1
    class ShareTreesController < ApplicationController
      def show
        @donation = Donation.find params[:id]
        render(json: share_tree_json, status: :ok)
      end

      private
      def share_tree_json
        {
          parent: parent,
          children: children
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
        @donation.children.limit(2).map do |child|
          {donation: child,
           name: child.user.name,
           image_url: child.user.get_gravatar_url
          }
        end
      end
    end
  end
end
