module Api
  module V1
    class ShareTreesController < ApplicationController
      def show
        @donation = Donation.find params[:id]
        render(json: {
          donation: {
            donation: @donation,
            name: @donation.user.name,
            email: @donation.user.email
          },
          downline: @donation.children.map{|child| {donation: child, name: child.user.name, email: child.user.email}}
        },
        status: :ok)
      end
    end
  end
end
