Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth', controllers:  { omniauth_callbacks: "overrides/omniauth_callbacks" }

  constraints :subdomain => 'api' do
    namespace :api, path: nil, defaults: {format: 'json'}  do
      namespace :v1 do
        resources :donations, only: [:create, :show, :update]
        resources :share_trees, only: [:show]
        resources :organizations, only: [:show]
        resources :names, only: [:show]
        resource :user_subscription, only: [:destroy]
        resources :user_donations, only: [:show]
        resources :accounts, only: [:show]
        get 'leaders/(:limit)' => 'leader_board#index'
        post 'subscribe/:id' => 'mailchimp#subscribe'
      end
    end
  end
  get 'omniauth/:provider' => 'overrides/omniauth_callbacks#redirect_callbacks'
  constraints :subdomain => 'amala' do
    namespace :amala, path: nil, defaults: {format: 'json'}  do
      get '/', to: redirect('/')
    end
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
