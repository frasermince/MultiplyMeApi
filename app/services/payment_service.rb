class PaymentService
  def initialize(strategy_array)
    @strategy_array = strategy_array
  end

  def pay
    @strategy_array.each{|strategy| strategy.pay}
  end
end
