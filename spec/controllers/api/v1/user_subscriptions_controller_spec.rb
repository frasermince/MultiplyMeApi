require 'rails_helper'

describe Api::V1::UserSubscriptionsController do
  login_user
  before { allow(controller).to receive(:current_user) { @user } }
  describe '#destroy' do
    it 'deletes all of the users donations' do
      create(:donation)
      @user.donations.each do |donation|
        expect(donation).to receive(:delete_subscription)
      end
      delete :destroy
    end
  end
end
