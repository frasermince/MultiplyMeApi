require 'rails_helper'

RSpec.configure do |c|
  c.include DonationAmounts
  c.include DonationCreator
end

describe Api::V1::UserSubscriptionsController do
  login_user
  before { allow(controller).to receive(:current_user) { @user } }
  describe '#destroy' do
    it 'deletes all of the users donations' do
      create_two_children
      @user.donations.each do |donation|
        allow(donation).to receive(:delete_subscription)
        expect(donation).to receive(:delete_subscription)
      end
      #@user.donations.each do |donation|
        #puts "***HERE #{customer.subscriptions.retrieve(donation.organization.get_stripe_user(@user))}"
      #end
      delete :destroy
      #expect(@user.
    end
  end
end
