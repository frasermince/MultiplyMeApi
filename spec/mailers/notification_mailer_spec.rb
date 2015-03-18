require "rails_helper"

RSpec.describe NotificationMailer, :type => :mailer do
  describe '#send_notification_email' do
    it 'sets the user based on parameter' do
      user = create(:user)
      mail = NotificationMailer.send_notification_email user
      expect(mail.to).to eql([user.email])
    end
  end
end
