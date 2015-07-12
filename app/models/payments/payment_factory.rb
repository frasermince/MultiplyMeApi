module Payments
  class PaymentFactory
    def initialize(donation)
      @child = donation
      @parent = donation.parent
      @strategy_array = []
      build_strategies
      @strategy_array
    end

    def self.new(*args, &block)
      obj = self.allocate
      array = obj.send :initialize, *args, &block
      PaymentService.new array
    end

    private
    def build_strategies
      child_build
      parent_build
    end

    def child_build
      unless @child.is_challenged
        add_strategy @child
      end
    end

    def parent_build
      policy = CompletedChallengePolicy.new @parent
      if @parent.present? && policy.challenge_completed?
        add_strategy @parent
      end
    end

    def add_strategy(donation)
      strategy = choose_strategy donation
      if strategy.present?
        @strategy_array.push strategy.new(donation)
      end
    end

    def choose_strategy(donation)
      if donation.is_subscription
        Payments::SubscriptionPayment
      else
        Payments::OneTimePayment
      end
    end

  end
end
