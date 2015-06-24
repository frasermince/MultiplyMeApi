require "rails_helper"

RSpec.describe NotificationMailer, :type => :mailer do
  describe '#finish_challenge' do
    it 'sets the user based on parameter' do
      you = create(:user)
      friend = create(:second_user)

      mail = NotificationMailer.finish_challenge you, friend
      expect(mail.to).to eql([you.email])
    end
  end
end
