module Pledgeable
  extend ActiveSupport::Concern
  included do
    after_create :after_create
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
    if self.is_challenged
      NotificationMailer.send_notification_email(self.user).deliver
    else
      self.purchase
    end
    if parent.present? && parent.challenge_completed?
      parent.purchase
    end
  end

  def challenge_completed?
    self.children.count == 3 && self.created_at > 3.days.ago
  end

  def create_subscription
    Stripe.api_key = self.organization.stripe_access_token
    customer = Stripe::Customer.retrieve self.user.stripe_id
    subscription = customer.subscriptions.create(
      application_fee_percent: PERCENTAGE_FEE,
      plan: 'pledge',
      quantity: self.amount
    )
    self.stripe_id = subscription.id
    self.save

  end

  def create_charge
    Stripe.api_key = self.organization.stripe_access_token
    charge = Stripe::Charge.create(
      amount: amount,
      currency: 'usd',
      customer: self.user.stripe_id,
      application_fee: (amount * (PERCENTAGE_FEE / 100)).round
    )
    self.stripe_id = charge.id
    self.save
  end

  def purchase
    unless self.is_paid
      self.is_subscription ? self.create_subscription : self.create_charge
      self.user.add_to_impact self
      self.is_paid = true
      self.save
      return true
    end
    false
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

end
