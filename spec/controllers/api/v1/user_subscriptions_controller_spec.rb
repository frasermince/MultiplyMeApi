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
        allow(donation).to receive(:destroy)
        expect(donation).to receive(:destroy)
      end
      delete :destroy
    end
  end
end
