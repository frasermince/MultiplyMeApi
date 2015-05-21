require 'rails_helper'

describe Api::V1::EmailSubscriptionsController do
  login_user
  describe '#create' do
    it 'sets the users is_subscribed field to true' do
      get :create
      expect(@user.reload.is_subscribed).to eq(true)
    end
  end

  describe '#destroy' do
    it 'sets the users is_subscribed field to false' do
      delete :destroy
      expect(@user.reload.is_subscribed).to eq(false)
    end
  end

end
