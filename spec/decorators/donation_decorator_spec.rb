require 'rails_helper'

RSpec.configure do |c|
  c.include DonationCreator
  c.include DonationAmounts
  c.include StripeHelpers
end

RSpec.describe DonationDecorator do
  before (:each) do
    @user = create(:user)
    @token_hash = {token: create_token, email: 'email@email.com'}
  end
  describe '#call_payment_service' do
    context 'receives a challenge' do
      it 'does not create a purchase for self' do
        allow_any_instance_of(PaymentService).to receive(:purchase).and_return({status: :success})
        expect_any_instance_of(PaymentService).not_to receive(:purchase)
        create_parent
        donation_decorator = DonationDecorator.new @parent_donation, @token_hash, @user, false
        donation_decorator.instance_eval{call_payment_service}
      end

      context 'challenge_completed? is true' do
        it 'does call purchase' do
          #should stub challenge_completed but this causes a strange error
          #allow_any_instance_of(Donation)
          #  .to receive(:challenge_completed?)
          #  .and_return(true)

          allow_any_instance_of(PaymentService)
            .to receive(:purchase)
            .and_return({status: :success})

          expect_any_instance_of(PaymentService)
            .to receive(:purchase)

          create_three_children
          donation_decorator = DonationDecorator.new @third_child, @token_hash, @user, false
          donation_decorator.instance_eval{call_payment_service}
        end
      end

      context 'challenge_completed? is false' do
        it 'does not call purchase' do

          allow_any_instance_of(CompletedChallengePolicy)
            .to receive(:challenge_completed?)
            .and_return(false)

          allow_any_instance_of(PaymentService)
            .to receive(:purchase)
            .and_return({status: :success})

          expect_any_instance_of(PaymentService)
            .not_to receive(:purchase)
          create_one_child
          donation_decorator = DonationDecorator.new @child_donation, @token_hash, @user, false
          donation_decorator.instance_eval{call_payment_service}
        end
      end
    end

    context 'if it is not a challenge' do
      context 'if purchase returns false' do
        it 'throws an error' do
          allow_any_instance_of(PaymentService)
            .to receive(:purchase).and_return({status: :failed, error: 'This is a test'})
          create_parent false
          donation_decorator = DonationDecorator.new @parent_donation, @token_hash, @user, false
          expect {donation_decorator.pay}
            .to raise_error
        end
      end

      it 'does create a purchase for self' do
        allow_any_instance_of(PaymentService).to receive(:purchase).and_return({status: :success})
        expect_any_instance_of(PaymentService).to receive(:purchase)
        create_parent false
        donation_decorator = DonationDecorator.new @parent_donation, @token_hash, @user, false
        donation_decorator.instance_eval{call_payment_service}
      end
    end
  end

  describe 'save' do
    it 'handles all before and after processes for saving a donation' do
      create_parent
      donation_decorator = DonationDecorator.new @parent_donation, @token_hash, @user, false
      expect(donation_decorator.save).to eq(true)
    end

  end
  describe '#subscribe_to_mail' do
    context 'when subscribe is true' do
      it 'adds user to mailing list' do
        allow_any_instance_of(MailingListService).to receive(:mailing_subscribe)
        expect_any_instance_of(MailingListService).to receive(:mailing_subscribe)
        create_parent
        donation_decorator = DonationDecorator.new @parent_donation, @token_hash, @user, true
        donation_decorator.instance_eval{subscribe_to_mail}
      end
    end

    context 'when subscribe is false' do
      it 'does not add user to mailing list' do
        expect_any_instance_of(MailingListService).not_to receive(:mailing_subscribe)
        create_parent
        donation_decorator = DonationDecorator.new @parent_donation, @token_hash, @user, false
        donation_decorator.instance_eval{subscribe_to_mail}

      end
    end
  end

end
