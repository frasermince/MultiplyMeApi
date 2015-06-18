require 'rails_helper'

RSpec.configure do |c|
  c.include DonationCreator
  c.include DonationAmounts
end

RSpec.describe Pledgeable do
=begin
  describe '#send_mail' do
    context 'self.is_challenged is true' do
      it 'sends a pledged email' do
        create_parent
        mailing_stubs false, false, false
        expect {@parent_donation.send_mail}
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
    context 'self.is_challenged is false' do
      it 'sends a donation email' do
        allow_any_instance_of(Donation).to receive(:purchase).and_return({status: :success})
        expect_any_instance_of(Donation).to receive(:purchase)
        donation = create(:unchallenged_donation)
        mailing_stubs false, false, false
        expect {donation.send_mail}
          .to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end
    context 'self.one_grandchild is true' do
      it 'sends a first_grandchild email' do
        mailing_stubs true, false, false
        create_grandchild
        expect {@grandchild_donation.send_mail}
          .to change { ActionMailer::Base.deliveries.count }.by(2)
      end
    end
    context 'can_still_complete? is true' do
      it 'sends a completion email' do
        mailing_stubs false, true, true
        create_one_child
        expect {@child_donation.send_mail}
          .to change { ActionMailer::Base.deliveries.count }.by(3)
      end
    end
    context 'can_still_complete? is true' do
      context 'and there is one child' do
        it 'sends a first friend email' do
          mailing_stubs false, false, true
          create_one_child
          expect {@child_donation.send_mail}
            .to change { ActionMailer::Base.deliveries.count }.by(2)
        end
      end
      context 'and there are two children' do
        it 'sends a first friend email' do
          mailing_stubs false, false, true
          create_two_children
          expect {@second_child.send_mail}
            .to change { ActionMailer::Base.deliveries.count }.by(2)
        end
      end
    end
  end
=end

  describe '#find_cycle' do
    context 'does not have an ancestor from the same user' do
      it 'returns nil' do
        create_different_user_donations
        expect(@third_child.parent.find_cycle(@third_child.user)).to be_nil
      end
    end
    context 'does have an ancestor donation from the same user' do

      it 'returns this ancestor' do
        create_two_children
        expect(@child_donation.parent.find_cycle(@child_donation.user)).to eq(@parent_donation)
      end
    end
  end

  describe '#user_cycles?' do
    context 'parent is nil' do
      it 'returns false' do
        create_parent
        expect(@parent_donation.user_cycles?).to be_falsey
      end
    end
    context 'find_cycle returns a donation' do
      it 'returns true' do
        create_one_child
        allow_any_instance_of(Donation).to receive(:find_cycle).and_return(@parent_donation)
        expect(@child_donation.user_cycles?).to be_truthy
      end
      context 'find_cycle returns nil' do
        it 'returns false' do
          create_one_child
          allow_any_instance_of(Donation).to receive(:find_cycle).and_return(nil)
          expect(@child_donation.user_cycles?).to be_falsey
        end
      end
    end
  end

  describe '#yearly_amount' do
    context 'donation is a subscription' do
      it "returns the donation's amount multiplyed by twelve" do
        donation = create(:subscription_donation)
        expect(donation.yearly_amount).to eq(donation.amount * 12)
      end
    end
    context 'donation is not a subscription' do
      it "returns the donation's amount" do
        donation = create(:nonsubscription_donation)
        expect(donation.yearly_amount).to eq(donation.amount)
      end
    end
  end

  describe '#subscription_length' do
    context 'is a subscription' do
      it 'calculates the amount of months' do
        donation = create(:parent)
        expect(donation.subscription_length(1.month.ago)).to eq(1)
      end
    end
    context 'is not a subscription' do
      it 'returns 0' do
        donation = create(:nonsubscription_donation)
        expect(donation.subscription_length(1.month.ago)).to eq(0)
      end
    end
  end

  describe '#delete_subscription' do
    context 'donation is a subscription' do
      it 'deletes the subscription' do
        donation = create(:stripe_donation)
        payment_service = PaymentService.new(donation)
        payment_service.create_subscription
        expect_any_instance_of(Stripe::Subscription).to receive(:delete)
        expect{donation.delete_subscription}.not_to raise_error
        expect(donation.is_cancelled).to eq(true)
      end
    end
    context 'donation is not a subscription or is not paid' do
      it 'does nothing' do
        donation = create(:unpaid_stripe_donation)
        expect_any_instance_of(Stripe::Subscription).not_to receive(:delete)
        donation.delete_subscription
      end
    end
  end
  def mailing_stubs(grandchild, completed, can_complete)
    allow_any_instance_of(Donation)
      .to receive(:one_grandchild)
      .and_return(grandchild)
    allow_any_instance_of(Donation)
      .to receive(:challenge_completed?)
      .and_return(completed)
    allow_any_instance_of(Donation)
      .to receive(:can_still_complete?)
      .and_return(can_complete)
  end
end
