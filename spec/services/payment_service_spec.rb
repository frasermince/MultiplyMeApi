require 'rails_helper'

RSpec.describe PaymentService do
  describe '#pay' do
    it 'calls pay on each strategy' do
      strategies = [double('first_strategy'), double('second_strategy')]
      strategies.each do |strategy|
        allow(strategy)
          .to receive(:pay)
        expect(strategy)
          .to receive(:pay)
      end
      payment_service = PaymentService.new strategies
      payment_service.pay
    end
  end
end
