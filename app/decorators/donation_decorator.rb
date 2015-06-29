class DonationDecorator
  def initialize(donation, card_params, user, subscribe_to_mail, referrer=nil)
    @donation = donation
    @donation.user = user
    @donation.parent_id = ReferralCodeService.find_id_by_code(referrer)
    @subscribe_to_mail = subscribe_to_mail
    @card_params = card_params
    @parent_payment_service = PaymentService.new @donation.parent
    @donation_payment_service = PaymentService.new @donation
    @mailing_list_service = MailingListService.new(@donation.user)
    @stripe_user_service = StripeUserService.new(@donation.user)
    @errors = []
    @notification_service = NotificationService.new @donation
  end

  def save
    @donation.transaction do
      contains_card &&
        @stripe_user_service.save_stripe_user(@card_params) &&
        @donation.save &&
        call_payment_service &&
        @notification_service.send_mail &&
        subscribe_to_mail
    end
  end

  def errors
    errors = @errors
    # include errors from saving the stripe user
    unless contains_card
      errors.push 'card not provided'
    end
    errors.concat @mailing_list_service.errors
    errors.concat @donation.errors.full_messages
    errors.concat @parent_payment_service.errors
    errors.concat @donation_payment_service.errors
    errors.concat @stripe_user_service.errors
  end

  private
  def subscribe_to_mail
    if @subscribe_to_mail
      @mailing_list_service.mailing_subscribe('c8e3eb0f3a')
    else
      true
    end
  end

  def contains_card
    @card_params[:email].present? && @card_params[:token].present?
  end

  def call_payment_service
    parent_result = true
    child_result = true
    parent = @donation.reload.parent
    unless @donation.is_challenged
      child_result = @donation_payment_service.purchase
    end
    policy = CompletedChallengePolicy.new parent
    if parent.present? && policy.challenge_completed?
      parent_result = @parent_payment_service.purchase
    end
    parent_result && child_result
  end

end
