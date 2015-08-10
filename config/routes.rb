Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers:  { omniauth_callbacks: "overrides/omniauth_callbacks" }

  #constraints :subdomain => 'api' do
    namespace :api, path: nil, defaults: {format: 'json'}  do
      namespace :v1 do
        resources :donations, only: [:create, :show, :update]
        resources :donation_reminders, only: [:create]
        resources :share_trees, only: [:show]
        resources :organizations, only: [:show]
        resources :names, only: [:show]
        resource :user_subscription, only: [:destroy]
        resources :user_donations, only: [:show]
        resources :accounts, only: [:show]
        resources :challenged_pledges, only: [:index]
        resource :email_subscriptions, only: [:create, :destroy]
        get 'leaders/(:limit)' => 'leader_board#index'
        post 'subscribe/:id' => 'mailchimp#subscribe'
      end
    end
  #end
  #get 'omniauth/:provider' => 'overrides/omniauth_callbacks#redirect_callbacks'
end
