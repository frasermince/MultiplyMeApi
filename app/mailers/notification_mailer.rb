include ActionView::Helpers::NumberHelper
class NotificationMailer < ActionMailer::Base
  default from: 'team@multiplyme.in'
  def finish_challenge(you, friend)
    set_friend_instance you
    @friend_name = friend.name
    mail(from: 'MultiplyMe', to: you.email, subject: 'Congratulations')
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
    social_links your_donation, @impact
    mail(from: 'MultiplyMe', to: you.email, subject: 'Your network impact is growing!')
  end

  def pledged(user, donation)
    per_month(donation)
    @name = user.name
    @amount = convert_amount(donation.amount)
    @share_link = share donation.id
    mail(from: 'MultiplyMe', to: user.email, subject: 'Thank you for taking the challenge')
  end

  def donated(user, donation)
    per_month(donation)
    @name = user.name
    @share_link = share donation.id
    @amount = convert_amount(donation.amount)
    mail(from: 'MultiplyMe', to: user.email, subject: 'Thank you for donating')
  end

  private
  def convert_amount(amount)
    (amount * 0.01)
  end
  def social_links(donation, impact)
    @facebook = '//www.facebook.com/sharer/sharer.php?u=https://amala.multiplyme.in/?_escaped_fragment_=share/' + donation.id.to_s
    @twitter = "//www.twitter.com/intent/tweet?text=My network raised #{number_to_currency impact} to help the Bhatti Mines School #{share(donation.id)} @AmalaFoundation @MultiplyMeIn"
  end
  def per_month(donation)
    if donation.is_subscription
      @per_month = ' a month'
    else
      @per_month = ''
    end
  end
  def set_friend_instance(you)
    @your_name = you.name
    @impact = convert_amount(you.network_impact)
  end
  def share(donation_id)
    'https://amala.multiplyme.in/#!/share/' + donation_id.to_s
  end
end
