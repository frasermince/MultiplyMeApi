require 'rails_helper'

RSpec.configure do |c|
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
        expect_any_instance_of(PaymentService).not_to receive(:purchase)
        donation = create(:donation)
        donation_decorator = DonationDecorator.new donation, @token_hash, @user, false
        donation_decorator.instance_eval{call_payment_service}
      end

      context 'challenge_completed? is true' do
        it 'does call purchase' do
          expect_any_instance_of(CompletedChallengePolicy)
            .to receive(:challenge_completed?)
            .and_return(true)

          expect_any_instance_of(PaymentService)
            .to receive(:purchase)
            .and_return({status: :success})

          parent = create(:donation)
          child = create(:donation)
          child.update_attribute('parent_id', parent.id)
          donation_decorator = DonationDecorator.new child, @token_hash, @user, false
          donation_decorator.instance_eval{call_payment_service}
        end
      end

      context 'challenge_completed? is false' do
        it 'does not call purchase' do

          expect_any_instance_of(CompletedChallengePolicy)
            .to receive(:challenge_completed?)
            .and_return(false)

          expect_any_instance_of(PaymentService)
            .not_to receive(:purchase)

          parent = create(:donation)
          child = create(:donation)
          child.update_attribute('parent_id', parent.id)

          donation_decorator = DonationDecorator.new child, @token_hash, @user, false
          donation_decorator.instance_eval{call_payment_service}
        end
      end
    end

    context 'if it is not a challenge' do
      context 'if purchase returns false' do
        it 'returns false' do
          allow_any_instance_of(PaymentService)
            .to receive(:purchase)
            .and_return(false)
          donation = create(:donation)
          donation.update_attribute('is_challenged', false)
          donation_decorator = DonationDecorator.new donation, @token_hash, @user, false

          expect(donation_decorator.instance_eval{call_payment_service})
            .to be_falsey
        end
      end

      it 'does create a purchase for self' do
        expect_any_instance_of(PaymentService)
          .to receive(:purchase)
          .and_return({status: :success})
        donation = create(:donation)
        donation.update_attribute('is_challenged', false)
        donation_decorator = DonationDecorator.new donation, @token_hash, @user, false
        donation_decorator.instance_eval{call_payment_service}
      end
    end
  end

  describe 'save' do
    it 'handles all before and after processes for saving a donation' do
      donation = create(:donation)
      donation_decorator = DonationDecorator.new donation, @token_hash, @user, false
      expect(donation_decorator.save).to eq(true)
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

end
