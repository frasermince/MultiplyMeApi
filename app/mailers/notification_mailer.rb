include ActionView::Helpers::NumberHelper
class NotificationMailer < ActionMailer::Base
  default from: 'team@multiplyme.in'
  def finish_challenge(you, friend, organization_id)
    set_friend_instance you, organization_id
    @friend_name = friend.name
    mail(from: 'MultiplyMe', to: you.email, subject: 'Congratulations')
  end

  def first_friend(you, your_donation, friend, organization_id)
    set_friend_instance(you, organization_id)
    @friend_name = friend.name
    @share_link = share your_donation.referral_code
    @days = your_donation.time_remaining
    mail(from: 'MultiplyMe', to: you.email, subject: 'Great News! Great Friends!')
  end

  def second_friend(you, your_donation, friend, organization_id)
    set_friend_instance(you, organization_id)
    @friend_name = friend.name
    @share_link = share your_donation.referral_code
    @days = your_donation.time_remaining
    mail(from: 'MultiplyMe' ,to: you.email, subject: 'Two Down! One to Go!')
  end

  def thank_friend(friend, content)
    @content = content
    @your_name = friend.name
    mail(from: 'MultiplyMe', to: friend.email, subject: 'Thank you!')
  end

  def remind_friend(you, your_donation, organization_id)
    set_friend_instance(you, organization_id)
    @remaining_friends = 3 - your_donation.children.count
    @share_link = share your_donation.referral_code
    @days = your_donation.time_remaining
    mail(from: 'MultiplyMe' ,to: you.email, subject: 'Friendly Reminder from MultiplyMe!')
  end

  def first_grandchild(you, your_donation, organization_id)
    set_friend_instance(you, organization_id)
    social_links your_donation, @impact
    mail(from: 'MultiplyMe', to: you.email, subject: 'Your network impact is growing!')
  end

  def pledged(user, donation)
    per_month(donation)
    @name = user.name
    @amount = convert_amount(donation.amount)
    @share_link = share donation.referral_code
    mail(from: 'MultiplyMe', to: user.email, subject: 'Thank you for taking the challenge')
  end

  def donated(user, donation)
    per_month(donation)
    @name = user.name
    @share_link = share donation.referral_code
    @amount = convert_amount(donation.amount)
    mail(from: 'MultiplyMe', to: user.email, subject: 'Thank you for donating')
  end

  private
  def convert_amount(amount)
    (amount * 0.01)
  end
  def social_links(donation, impact)
    @facebook = '//www.facebook.com/sharer/sharer.php?u=https://backonmyfeet.multiplyme.in/?_escaped_fragment_=share/' + donation.referral_code
    @twitter = "//www.twitter.com/intent/tweet?text=My network raised #{number_to_currency impact} to help Back On My Feet #{share(donation.referral_code)} @backonmyfeet @MultiplyMeIn"
  end
  def per_month(donation)
    if donation.is_subscription
      @per_month = ' a month'
    else
      @per_month = ''
    end
  end
  def set_friend_instance(you, organization_id)
    @your_name = you.name
    @impact = convert_amount(you.network_impact(organization_id))
  end
  def share(referral_code)
    'https://backonmyfeet.multiplyme.in/#!/share/' + referral_code
  end
end
