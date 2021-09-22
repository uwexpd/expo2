Rails.application.routes.draw do
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  
  root to: redirect('expo'), :as => 'redirect_root'
  get '/auth/:provider/callback', to: 'sessions#create'
  
  scope 'expo' do
    
    root 'admin/dashboard#index'
    ##### Custom active admin routes ##############
    # DEPRECATION WARNING: Using a dynamic :action: get 'admin/apply/:offering/:action', to: 'admin/apply#:action', as: :admin_apply_action
    get 'admin/apply/:offering', to: 'admin/apply#manage', as: :admin_apply_manage
    get 'admin/apply/:offering/list', to: 'admin/apply#list', as: :admin_apply_list
    get 'admin/apply/:offering/awardees', to: 'admin/apply#awardees', as: :admin_apply_awardees
    post 'admin/base/vicarious_login', :to => 'admin/base#vicarious_login', as: :admin_vicarious_login
    get 'admin/base/remove_vicarious_login', :to => 'admin/base#remove_vicarious_login', as: :admin_remove_vicarious_login
    ActiveAdmin.routes(self)
    # namespace :admin do
    #   resources :offerings do
    #     resources :offering_admin_phases do
    #       resources :offering_admin_phase_tasks
    #     end
    #   end    
    # end
    namespace :admin do
      resources :offerings do
        resources :applications
        resources :pages do
          resources :questions do
            resources :validations
            resources :options
          end
        end
        resources :statuses do
          resources :emails
        end
      end
    end
    
    # User and Sessions    
    resources :sessions    
    get 'signup',  to: 'users#new'
    get 'login',  to: 'sessions#new'
    match 'logout', to: 'sessions#destroy', via: [:get, :delete]
    get 'remove_vicarious_login', :to => 'application#remove_vicarious_login'
    resources :users, only: [:create, :update]


    # RSVP for events
    get 'rsvp/event/:id', to: 'rsvp#event', as: :rsvp_event
    get 'rsvp/attend/:id', to: 'rsvp#attend', as: :rsvp_attend
    get 'rsvp/unattend/:id', to: 'rsvp#unattend', as: :rsvp_unattend
    get 'rsvp', to: 'rsvp#index'

    # Online Applications
    # get 'apply/:offering/:action', to: 'apply#:action', :requirements => { :offering => /\d+/ }, as: :apply_action
    get 'apply/:offering/', to: 'apply#index', :requirements => { :offering => /\d+/ }, as: :apply


    # OMSFA Scholarship Sesarch
    resources :scholarships, only: [:show, :index], param: :page_stub

    # MGE Scholars Search
    resources :mge_scholars, only: [:show, :index]

    # URP Opportunities Sesarch
    get 'opportunities/research', to: 'opportunities#research', as: :opportunity_research
    match 'opportunities/form', to: 'opportunities#form', via: [:get, :post, :put, :patch], as: :opportunity_form
    match 'opportunities/form/:id', to: 'opportunities#form', via: [:get, :post, :put, :patch]
    match 'opportunities/submit/:id', to: 'opportunities#submit', via: [:get, :post, :put, :patch]
    resources :opportunities, only: [:show, :index]

    # Service Learning
    # Name change from service_learning to community_engaged
    match 'community_engaged', to: 'service_learning#index', via: [:get, :post], :quarter_abbrev => 'current', as: :community_engaged
    match 'community_engaged/:action', to: 'service_learning#:action', via: [:get, :post, :put, :patch], :quarter_abbrev => 'current'
    match 'community_engaged/:action/:id', to: 'service_learning#:action', via: [:get, :post, :put, :patch], :quarter_abbrev => 'current', as: :community_engaged_action
    #################################################################
    match 'service_learning', to: 'service_learning#index', via: [:get, :post
    ], :quarter_abbrev => 'current', as: :service_learning
    match 'service_learning/:action', to: 'service_learning#:action', via: [:get, :post, :put, :patch], :quarter_abbrev => 'current'
    match 'service_learning/:action/:id', to: 'service_learning#:action', via: [:get, :post, :put, :patch], :quarter_abbrev => 'current', as: :service_learning_action
  end
  
  # Redirect to Sub URI only when it doesn't match '/expo/' in the request URLs
  constraints ->(req) { !req.url.match('/expo/') } do
      get "/*all", to: redirect{|params, request| "/expo/#{params[:all]}"}
  end

end
