class NotificationMailer < ActionMailer::Base
  default from: 'team@multiplyme.in'
  def send_notification_email(user)
    mail(to: user.email, subject: 'Three days to invite your friends!')
  end
end
