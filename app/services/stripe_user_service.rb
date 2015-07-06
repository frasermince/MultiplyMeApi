require 'stripe'
class StripeUserService
  def initialize(user)
    @user = user
    @stripe_client = StripeClient.new
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
    result = @stripe_client.create_stripe_user(params)
    result != false ? result.id : false
  end

  def add_credit_card(token)
    Stripe.api_key = Rails.application.secrets.stripe_secret_key
    if @user.stripe_id.present?
      @stripe_client.create_credit_card token, @user
      true
    else
      #@errors.push 'customer is not present'
      return false
    end
  end
end
