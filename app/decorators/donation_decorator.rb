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

  def save!
    if contains_card
      do_transaction
    else
      raise 'No card information is passed'
    end
  end

  private
  def do_transaction
    @donation.transaction do
      donation_flow
    end
  end

  def donation_flow
    StripeUserService.new(@donation.user).save_stripe_user(@card_params)
    @donation.save!
    Payments::PaymentFactory.new(donation).pay
    NotificationService.new(@donation).send_mail
    #subscribe_to_mail
  end

  def subscribe_to_mail
    if @subscribe_to_mail
      MailingListService.new(@donation.user).mailing_subscribe('c8e3eb0f3a')
    end
  end

  def contains_card
    @card_params[:email].present? && @card_params[:token].present?
  end
end
