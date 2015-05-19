Rails.application.config.middleware.use OmniAuth::Builder do
  provider :stripe_connect,
    Rails.application.secrets.stripe_client_id,
    Rails.application.secrets.stripe_secret_key
  provider :facebook, Rails.application.secrets.facebook_app_id, Rails.application.secrets.facebook_secret_key
end
