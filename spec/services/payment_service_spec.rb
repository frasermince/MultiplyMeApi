require 'rails_helper'

RSpec.configure do |c|
  c.include DonationCreator
  c.include DonationAmounts
end

RSpec.describe PaymentService do
  describe '#initialize' do
    context 'receives a challenge' do
      it 'does not create a purchase for self' do
        allow_any_instance_of(PaymentService).to receive(:purchase).and_return({status: :success})
        expect_any_instance_of(PaymentService).not_to receive(:purchase)
        create_parent
        payment_service = PaymentService.new @parent_donation
        payment_service.pay
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
          payment_service = PaymentService.new @third_child
          payment_service.pay
        end
      end

      context 'challenge_completed? is false' do
        it 'does not call purchase' do

          allow_any_instance_of(PaymentService)
            .to receive(:challenge_completed?)
            .and_return(false)

          allow_any_instance_of(PaymentService)
            .to receive(:purchase)
            .and_return({status: :success})

          expect_any_instance_of(PaymentService)
            .not_to receive(:purchase)
          create_one_child
          payment_service = PaymentService.new @child_donation
          payment_service.pay
        end
      end
    end

    context 'if it is not a challenge' do
      context 'if purchase returns false' do
        it 'throws an error' do
          allow_any_instance_of(PaymentService)
            .to receive(:purchase).and_return({status: :failed, error: 'This is a test'})
          create_parent false
          payment_service = PaymentService.new @parent_donation
          expect {payment_service.pay}
            .to raise_error
        end
      end

      it 'does create a purchase for self' do
        allow_any_instance_of(PaymentService).to receive(:purchase).and_return({status: :success})
        expect_any_instance_of(PaymentService).to receive(:purchase)
        create_parent false
        payment_service = PaymentService.new @parent_donation
        payment_service.pay
      end
    end
  end

  describe '#challenge_completed?' do
    context 'has three children and is less than three days old' do
      it 'returns true' do
        allow_any_instance_of(PaymentService)
          .to receive(:purchase)
          .and_return(true)
        create_three_children
        payment_service = PaymentService.new @parent_donation
        expect(payment_service.challenge_completed?(@parent_donation)).to be_truthy
      end
    end

    context 'is more than three days old' do
      it 'returns false' do
        allow_any_instance_of(PaymentService)
          .to receive(:purchase)
          .and_return(true)
        create_three_children true
        payment_service = PaymentService.new @third_child
        expect(payment_service.challenge_completed?(@third_child)).to be_falsey
      end
    end

    context 'has less than three children' do
      it 'returns false' do
        allow_any_instance_of(PaymentService)
          .to receive(:purchase)
          .and_return(true)
        create_two_children
        payment_service = PaymentService.new @second_child
        expect(payment_service.challenge_completed?(@second_child)).to be_falsey
      end
    end
  end

  describe '#create_subscription' do
    context 'has a nil stripe id' do
      it 'throws an exception' do
        create_parent
        payment_service = PaymentService.new @parent_donation
        result = payment_service.create_subscription
        expect(result[:status]).to eq(:failed)
      end
    end
    context 'has a valid stripe id' do
      it 'creates a subscription' do
        donation = create(:stripe_donation)
        payment_service = PaymentService.new donation
        result = payment_service.create_subscription
        expect(result[:status]).to eq(:success)
        expect(donation.reload.stripe_id).to be
      end
    end
  end

  describe '#create_charge' do
    context 'has a nil stripe id' do
      it 'throws an exception' do
        create_parent
        payment_service = PaymentService.new @parent
        expect(payment_service.create_charge[:status]).to eq(:failed)
      end
    end
    context 'has a valid stripe id' do
      it 'creates a charge' do
        donation = create(:stripe_donation)
        payment_service = PaymentService.new donation
        expect(payment_service.create_charge[:status]).to eq(:success)
        expect(donation.reload.stripe_id).to be
      end
    end
  end

  describe '#purchase' do
    context 'succeeds in making a purchase' do

      context 'and donation is a subscription' do
        it 'calls create_subscription' do
          donation = create(:subscription_donation)
          allow_any_instance_of(PaymentService).to receive(:create_subscription).and_return({status: :success})
          expect_any_instance_of(PaymentService).to receive(:create_subscription)
          payment_service = PaymentService.new donation
          payment_service.purchase
        end
      end

      context 'and donation is not a subscription' do
        it 'calls create_charge' do
          donation = create(:nonsubscription_donation)
          allow_any_instance_of(PaymentService).to receive(:create_charge).and_return({status: :success})
          expect_any_instance_of(PaymentService).to receive(:create_charge)
          payment_service = PaymentService.new donation
          payment_service.purchase
        end
      end

      it 'returns a status of success' do
        allow_any_instance_of(PaymentService).to receive(:create_subscription).and_return({status: :success})
        create_parent
        payment_service = PaymentService.new @parent_donation
        expect(payment_service.purchase).to be_truthy
      end
    end

    context 'purchase was previously made' do
      it 'returns a failed status' do
        create_paid
        payment_service = PaymentService.new @paid_donation
        expect(payment_service.purchase[:status]).to eq(:failed)
      end
    end

  end
end
