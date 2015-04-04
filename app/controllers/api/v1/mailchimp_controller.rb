require 'mailchimp'
module Api
  module V1
    class MailchimpController < ApplicationController

      before_action :mailchimp_api

      def subscribe
        list_id = params[:id]
        email = params['email']
        begin
          @mailchimp.lists.subscribe(params[:id], {'email' => email})
        rescue Mailchimp::Error => ex
          if ex.message
            msg = ex.message
          else
            msg = "An unknown error occurred"
          end
          render json: {error: msg}, :status => 500
          return
        end
        render json: { message: "Email subscribed successfully"}, :status => :ok
      end


      private
      def mailchimp_api
        @mailchimp = Mailchimp::API.new('28e127d80b3c82b4bf52e95e3ad0bb71-us10')
      end
    end
  end
end
