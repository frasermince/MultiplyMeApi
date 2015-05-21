module Pledgeable
  extend ActiveSupport::Concern
  included do
    after_create :after_create
    before_destroy :delete_subscription
  end

  def yearly_amount
    yearly = self.amount
    if self.is_subscription
      yearly *= 12
    end
    yearly
  end

  def after_create
    parent = self.parent
    unless self.is_challenged
      response = self.purchase
      if response[:status] == :failed
        raise Exception.new(response[:error])
      end
      response
    end
    if parent.present? && parent.challenge_completed?
      parent.purchase
    end
    self.send_mail
  end

  def send_mail
    parent = self.parent
    if self.is_challenged
      NotificationMailer.pledged(self.user, self).deliver_now
    else
      NotificationMailer.donated(self.user, self).deliver_now
    end
    if parent.present?
      grandparent = parent.parent
      if grandparent.present? && grandparent.one_grandchild
        NotificationMailer.first_grandchild(grandparent.user, grandparent).deliver_now
      end

      if parent.can_still_complete?
        if parent.children.count == 1
          NotificationMailer.first_friend(parent.user, parent, self.user).deliver_now
        elsif parent.children.count == 2
          NotificationMailer.second_friend(parent.user, parent, self.user).deliver_now
        end
      end

      if parent.challenge_completed?
        NotificationMailer.finish_challenge(parent.user).deliver_now
      end
    end
  end

  def can_still_complete?
    self.is_challenged && self.created_at > 3.days.ago
  end

  def challenge_completed?
    self.children.count == 3 && self.can_still_complete?
  end

  def create_subscription
    begin
      Stripe.api_key = Rails.application.secrets.stripe_secret_key
      customer = self.organization.get_stripe_user(user)
      subscription = customer.subscriptions.create({
        application_fee_percent: PERCENTAGE_FEE,
        plan: 'pledge',
        quantity: self.amount,
      }, stripe_account: self.organization.stripe_id)
      self.update_attribute('stripe_id', subscription.id)
    rescue => error
      return {status: :failed, error: error}
    end
    {status: :success}
  end

  def create_charge
    begin
      Stripe.api_key = Rails.application.secrets.stripe_secret_key
      customer = self.organization.get_stripe_user(user)
      charge = Stripe::Charge.create({
        amount: amount,
        application_fee: (amount * (PERCENTAGE_FEE / 100)).round,
        currency: 'usd',
        customer: customer.id
      }, stripe_account: self.organization.stripe_id)
      self.update_attribute('stripe_id', charge.id)
    rescue => error
      return {status: :failed, error: error}
    end
    {status: :success}
  end

  def purchase
    unless self.is_paid
      response = self.is_subscription ? self.create_subscription : self.create_charge
      self.update(is_paid: true) if response[:status] == :success
      return response
    end
    return {status: :failed, error: 'order has already been paid'}
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
        result.delete
      end
    end
  end
end
