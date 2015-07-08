class DonationDecorator
  def initialize(donation, card_params, user, subscribe_to_mail, referrer = nil)
    @donation = donation
    @donation.user = user
    @donation.parent_id = ReferralCodeService.find_id_by_code(referrer)
    @subscribe_to_mail = subscribe_to_mail
    @card_params = card_params
  end

  def donation
    @donation
  end

  def save
    @donation.transaction do
      contains_card &&
        StripeUserService.new(@donation.user).save_stripe_user(@card_params)
        @donation.save!
        call_payment_service
        @notification_service.send_mail
        subscribe_to_mail
    end
  end

  private
  def subscribe_to_mail
    if @subscribe_to_mail
      MailingListService.new(@donation.user).mailing_subscribe('c8e3eb0f3a')
    end
  end

  def contains_card
    @card_params[:email].present? && @card_params[:token].present?
  end

  def call_payment_service
    parent = @donation.reload.parent
    policy = CompletedChallengePolicy.new parent
    donation_purchase && parent_purchase(parent, policy)
  end

  def donation_purchase
    unless @donation.is_challenged
      PaymentService.new(@donation, @donation.organization).purchase
    end
  end

  def parent_purchase(parent, policy)
    if parent.present? && policy.challenge_completed?
      PaymentService.new(parent, parent.organization).purchase
    end
  end

end
