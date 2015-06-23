module Pledgeable
  extend ActiveSupport::Concern
  included do
    before_destroy :delete_subscription
  end

  def yearly_amount
    if self.is_subscription && self.is_cancelled && self.cancelled_time.present?
      months = ((self.cancelled_time.to_f - self.created_at.to_f) / (3600 * 24 * 30)).ceil
      self.amount * months
    else
      yearly = self.amount
      if self.is_subscription
        yearly *= 12
      end
      yearly
    end
  end

  def after_create
    PaymentService.new(self).pay
    #self.send_mail
  end

  def user_cycles?
    if self.parent.nil?
      false
    else
      !(self.parent.find_cycle self.user).nil?
    end
  end

  def find_cycle user
    if self.user == user
      self
    elsif self.parent.nil?
      nil
    else
      self.parent.find_cycle user
    end
  end

  def subscription_length(starting_timestamp)
    if self.is_subscription
      today = Time.now
      (today.year * 12 + today.month) - (starting_timestamp.year * 12 + starting_timestamp.month)
    else
      0
    end
  end

  def delete_subscription
    if self.is_subscription && self.is_paid
      customer = self.organization.get_stripe_user self.user
      subscriptions = customer.subscriptions
      unless subscriptions.data.empty?
        result = subscriptions.retrieve(self.stripe_id)
        self.update_attribute('is_cancelled', true)
        self.update_attribute('cancelled_time', DateTime.now)
        result.delete
      end
    end
  end
end
