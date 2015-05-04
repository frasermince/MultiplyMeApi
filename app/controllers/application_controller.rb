class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  include ActionController::RespondWith
  include DeviseTokenAuth::Concerns::SetUserByToken
  include DeviseTokenAuth::Controllers::Helpers
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
  def home

  end

  protected
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :name
  end

  private
  def record_not_found(error)
    render :json => {:error => error.message}, :status => :not_found
  end
end
