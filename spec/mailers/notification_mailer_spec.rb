require "rails_helper"

RSpec.describe NotificationMailer, :type => :mailer do
  describe '#finish_challenge' do
    it 'sets the user based on parameter' do
      you = create(:user)
      friend = create(:user)

      mail = NotificationMailer.finish_challenge you, friend, 1
      expect(mail.to).to eql([you.email])
    end
  end
end
