module Api
  module V1
    class ShareTreesController < ApplicationController
      def show
        @donation = Donation.find params[:id]
        render(json: {
          donation: {
            donation: @donation,
            name: @donation.user.name
          },
          downline: @donation.children.map{|child| {donation: child, name: child.user.name}}
        },
        status: :ok)
      end
    end
  end
end
