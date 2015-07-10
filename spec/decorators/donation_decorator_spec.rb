require 'rails_helper'

RSpec.configure do |c|
  c.include StripeHelpers
end

RSpec.describe DonationDecorator do
  before (:each) do
    @user = create(:user)
    @token_hash = {token: create_token, email: 'email@email.com'}
  end

  describe '#save' do
    context 'card information is not passed' do
      it 'raises an error' do
        donation = create(:donation)
        donation_decorator = DonationDecorator.new donation, @token_hash, @user, false
        allow(donation_decorator)
          .to receive(:contains_card)
          .and_return(false)
        expect{donation_decorator.save}.to raise_error
      end
    end

    context 'card information is passed' do
      context 'step throws an exception' do
        it 'propogates the exception and rolls back' do
          donation = create(:donation)
          amount = 5
          donation.amount = amount
          donation_decorator = DonationDecorator.new donation, @token_hash, @user, false
          mock_user_service
          allow(Payments::PaymentFactory)
            .to receive(:new)
            .and_raise('exception')

          expect{donation_decorator.save}.to raise_error
          expect(donation.reload.amount).not_to eq(amount)
        end
      end

      context 'all steps are successful' do
        it 'handles all before and after processes for saving a donation' do
          donation = create(:donation)
          donation_decorator = DonationDecorator.new donation, @token_hash, @user, false
          mock_user_service
          mock_payment_service
          mock_notification_service
          allow(donation_decorator)
            .to receive(:subscribe_to_mail)
            .and_return(true)
          expect(donation_decorator)
            .to receive(:subscribe_to_mail)
          expect(donation_decorator.save).to eq(true)
        end
      end
    end

  end

  describe '#subscribe_to_mail' do
    context 'when subscribe is true' do
      it 'adds user to mailing list' do
        expect_any_instance_of(MailingListService).to receive(:mailing_subscribe)
        donation = create(:donation)
        donation_decorator = DonationDecorator.new donation, @token_hash, @user, true
        donation_decorator.instance_eval{subscribe_to_mail}
      end
    end

    context 'when subscribe is false' do
      it 'does not add user to mailing list' do
        expect_any_instance_of(MailingListService).not_to receive(:mailing_subscribe)
        donation = create(:donation)
        donation_decorator = DonationDecorator.new donation, @token_hash, @user, false
        donation_decorator.instance_eval{subscribe_to_mail}

      end
    end
  end

  def mock_payment_service
    payment_service = double('payment_service')
    allow(Payments::PaymentFactory)
      .to receive(:new)
      .and_return(payment_service)
    allow(payment_service)
      .to receive(:pay)
      .and_return(true)
    expect(payment_service)
      .to receive(:pay)
  end

  def mock_notification_service
    notification_service = double('notification_service')
    allow(NotificationService)
      .to receive(:new)
      .and_return(notification_service)
    allow(notification_service)
      .to receive(:send_mail)
      .and_return(true)
    expect(notification_service)
      .to receive(:send_mail)
  end

  def mock_user_service
    stripe_user_service = double('stripe_user_service')
    allow(StripeUserService)
      .to receive(:new)
      .and_return(stripe_user_service)
    allow(stripe_user_service)
      .to receive(:save_stripe_user)
      .and_return(true)
    expect(stripe_user_service)
      .to receive(:save_stripe_user)
  end
end
