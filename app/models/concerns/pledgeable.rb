module Pledgeable
  extend ActiveSupport::Concern
  included do
    after_create :after_create
  end

  def after_create
    parent = self.parent
    unless self.is_challenged
      self.purchase
    end
    if parent.present? && parent.children.count == 3
      parent.purchase
    end
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
      self.is_paid = true
      self.save
      return true
    end
    false
  end

end
