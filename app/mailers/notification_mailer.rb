class NotificationMailer < ActionMailer::Base
  default from: 'team@multiplyme.in'
  def finish_challenge(user)
    set_friend_instance user
    mail(from: 'MultiplyMe', to: user.email, subject: 'Congratulations')
  end

  def first_friend(you, your_donation, friend)
    set_friend_instance(you)
    @friend_name = friend.name
    @share_link = share your_donation.id
    @days = your_donation.time_remaining
    mail(from: 'MultiplyMe', to: you.email, subject: 'Great News! Great Friends!')
  end

  def second_friend(you, your_donation, friend)
    set_friend_instance(you)
    @friend_name = friend.name
    @share_link = share your_donation.id
    @days = your_donation.time_remaining
    mail(from: 'MultiplyMe' ,to: you.email, subject: 'Two Down! One to Go!')
  end

  def first_grandchild(you, your_donation)
    set_friend_instance(you)
    mail(from: 'MultiplyMe', to: you.email, subject: 'Your network impact is growing!')
  end

  def pledged(user, donation)
    @name = user.name
    @amount = convert_amount(donation.amount)
    @share_link = share donation.id
    mail(from: 'MultiplyMe', to: user.email, subject: 'Thank you for taking the challenge')
  end

  def donated(user, donation)
    @name = user.name
    @amount = convert_amount(donation.amount)
    mail(from: 'MultiplyMe', to: user.email, subject: 'Thank you for donating')
  end

  private
  def convert_amount(amount)
    (amount * 0.01)
  end
  def set_friend_instance(you)
    @your_name = you.name
    @impact = convert_amount(you.network_impact)
  end
  def share(donation_id)
    'https://amala.multiplyme.in/#/share/' + donation_id.to_s
  end
end
