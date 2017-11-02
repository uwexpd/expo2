Rails.application.routes.draw do
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  
  root to: redirect('expo'), :as => 'redirect_root'
  get '/auth/:provider/callback', to: 'sessions#create'
  
  scope 'expo' do
    
    root 'admin/dashboard#index'
    
    ActiveAdmin.routes(self)        
    
    # User and Sessions    
    resources :sessions
    get 'login',  to: 'sessions#new'
    delete 'logout', to: 'sessions#destroy'

    # RSVP for events
    get 'rsvp/event/:id', to: 'rsvp#event', as: :rsvp_event
    get 'rsvp/attend/:id', to: 'rsvp#attend', as: :rsvp_attend
    get 'rsvp/unattend/:id', to: 'rsvp#unattend', as: :rsvp_unattend
    get 'rsvp', to: 'rsvp#index'

    resources :scholarships, only: [:show, :index], param: :page_stub
    resources :mge_scholars, only: [:show, :index]
    
  end
  
  # Redirect to Sub URI only when it doesn't match '/expo/' in the request URLs
  constraints ->(req) { !req.url.match('/expo/') } do
      get "/*all", to: redirect{|params, request| "/expo/#{params[:all]}"}
  end
  
  
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
