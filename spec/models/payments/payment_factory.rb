require 'rails_helper'

RSpec.describe Payments::PaymentFactory do
  describe '#new' do
    context 'parent is present and not a subscription and child is challenged' do
      context 'parent has completed challenge' do
        it 'creates a OneTimePayment with the parent donation as a parameter' do
          parent = create(:donation)
          parent.update_attribute('is_subscription', false)
          child = create(:donation)
          child.parent_id = parent.id
          stub_policy(true)
          stub_one_time

          Payments::PaymentFactory.new child

          expect(Payments::OneTimePayment)
            .to have_received(:new)
            .with(parent)
        end
      end

      context 'parent has not completed challenge' do
        it 'does not call OneTimePayment' do
          parent = create(:donation)
          parent.update_attribute('is_subscription', false)
          child = create(:donation)
          child.parent_id = parent.id
          stub_policy(false)
          stub_one_time

          Payments::PaymentFactory.new child

          expect(Payments::OneTimePayment)
            .not_to have_received(:new)
            .with(parent)
        end
      end
    end

    context 'parent is not present' do

      context 'child is not challenged' do

        context 'child is a subscription' do
          it 'calls SubscriptionPayment.new with child' do
            child = create(:donation)
            child.update_attribute('is_challenged', false)
            child.update_attribute('is_subscription', true)
            stub_subscription
            Payments::PaymentFactory.new child

            expect(Payments::SubscriptionPayment)
              .to have_received(:new)
              .with(child)

          end
        end

        context 'child is not a subscription' do
          it 'calls OneTimePayment.new with child' do
            child = create(:donation)
            child.update_attribute('is_challenged', false)
            child.update_attribute('is_subscription', false)
            stub_one_time
            Payments::PaymentFactory.new child

            expect(Payments::OneTimePayment)
              .to have_received(:new)
              .with(child)
          end
        end

      end

      context 'child is challenged' do
        it 'does not call OneTimePayment.new or SubscriptionPayment.new' do
          child = create(:donation)
          child.update_attribute('is_challenged', true)
          stub_one_time
          stub_subscription
          Payments::PaymentFactory.new child
          expect(Payments::OneTimePayment)
            .not_to have_received(:new)
          expect(Payments::SubscriptionPayment)
            .not_to have_received(:new)
        end
      end

    end

  end

  def stub_policy(challenge_completed)
    policy = double 'policy'
    allow(CompletedChallengePolicy)
      .to receive(:new)
      .and_return(policy)
    allow(policy)
      .to receive(:challenge_completed?)
      .and_return(challenge_completed)
  end

  def stub_subscription
    subscription_payment = double('subscription_payment')
    allow(Payments::SubscriptionPayment)
      .to receive(:new)
      .and_return(subscription_payment)
  end

  def stub_one_time
    one_time_payment = double('one_time_payment')
    allow(Payments::OneTimePayment)
      .to receive(:new)
      .and_return(one_time_payment)
  end
end
