require 'mailchimp'
module Api
  module V1
    class MailchimpController < ApplicationController

      before_action :mailchimp_api

      def subscribe
        list_id = params[:id]
        email = params['email']
        begin
          @mailchimp.lists.subscribe(list_id , {'email' => email})
        rescue Mailchimp::Error => ex
          puts "***EX #{ex}"
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
        @mailchimp = Mailchimp::API.new Rails.application.secrets.mailchimp_api_key
      end
    end
  end
end
