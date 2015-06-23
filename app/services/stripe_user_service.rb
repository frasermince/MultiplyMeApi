require 'stripe'
class StripeUserService
  def initialize(user)
    @user = user
    @errors = []
  end

  def save_stripe_user(params)
    if @user.stripe_id.present?
      result = add_credit_card(params[:token])
    else
      result = create_stripe_user params
      @user.update_attribute('stripe_id', result) if result != false
    end
    result
  end

  def create_stripe_user(params)
    begin
      Stripe.api_key = Rails.application.secrets.stripe_secret_key
      customer = Stripe::Customer.create(
        {
          source: params[:token],
          email: params[:email]
        }
      )
    rescue => error
      @errors.push error.message
      return false
    end
    customer.id
  end

  def add_credit_card(token)
    begin
      Stripe.api_key = Rails.application.secrets.stripe_secret_key
      if @user.stripe_id.present?
        create_credit_card token
        true
      else
        @errors.push 'customer is not present'
        return false
      end
    rescue => error
      @errors.push error.message
      return false
    end
  end

  def errors
    @errors
  end

  def create_credit_card(token)
    begin
      customer = Stripe::Customer.retrieve(@user.stripe_id)
      customer.sources.create(:source => token)
    rescue => error
      @errors.push error.message
      return false
    end
  end

end
