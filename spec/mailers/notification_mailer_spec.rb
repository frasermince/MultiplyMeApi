require "rails_helper"

RSpec.describe NotificationMailer, :type => :mailer do
  describe '#finish_challenge' do
    it 'sets the user based on parameter' do
      user = create(:user)
      mail = NotificationMailer.finish_challenge user
      expect(mail.to).to eql([user.email])
    end
  end
end
