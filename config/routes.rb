require 'sidekiq/web'
Rails.application.routes.draw do
  
  root to: redirect('expo'), :as => 'redirect_root'
  get '/auth/:provider/callback', to: 'sessions#create'

  scope 'expo' do

    root 'admin/dashboard#index'
    # -------------------------------------------------------------------------------------------
    # Custom Active Admin Routes
    # -------------------------------------------------------------------------------------------
    get 'admin/apply/:offering', to: 'admin/apply#manage', as: :admin_apply_manage
    get 'admin/apply/:offering/list', to: 'admin/apply#list', as: :admin_apply_list
    get 'admin/apply/:offering/files/application_file/file/:id/:file', to: 'admin/apply#view', as: :admin_apply_file
    get 'admin/apply/:offering/files/application_mentor/letter/:id/:mentor', to: 'admin/apply#view', as: :admin_apply_letter    
    get 'admin/apply/:offering/awardees', to: 'admin/apply#awardees', as: :admin_apply_awardees
    post 'admin/base/vicarious_login', to: 'admin/base#vicarious_login', as: :admin_vicarious_login
    get 'admin/base/remove_vicarious_login', to: 'admin/base#remove_vicarious_login', as: :admin_remove_vicarious_login
    get 'admin/application_for_offerings', to: 'admin/applications#index'
    get 'admin/service_learning_placements', to: 'admin/dashboard#index' # [TODO] update when SLP is ready
    get 'admin/communicate/write', to: 'admin/email#write', as: :email_write
    post 'admin/communicate/queue', to: 'admin/email#queue', as: :email_queue
    get 'admin/communicate/apply_template', to: 'admin/email#apply_template'

    ActiveAdmin.routes(self)    
    namespace :admin do
      resources :offerings do
        resources :applications do
          patch :assign_session, on: :member
          resources :group_members
          resources :mentors
        end
        resources :pages do
          resources :questions do
            resources :validations
            resources :options
          end
        end
        resources :statuses do
          resources :emails
        end
        resources :phases do
          resources :tasks do
            resources :extra_fields
          end
        end
        resources :dashboard_items
        resources :restrictions do
          resources :exemptions
        end        
      end
      resources :contact_histories
      resources :committees do
        resources :members
        resources :committee_quarters
        resources :meetings
      end      
      resources :notes      
    end
    
    # -------------------------------------------------------------------------------------------
    # Public Routes
    # -------------------------------------------------------------------------------------------
    # User and Sessions            
    get 'signup',  to: 'users#new'
    match 'signup', to: 'users#create', via: [:post]
    get 'profile', to: 'users#profile'
    match 'profile', to: 'users#update', via: [:post, :put, :patch]
    resources :users, only: [:create, :update]
    get 'login',  to: 'sessions#new'
    match 'logout', to: 'sessions#destroy', via: [:get, :delete]
    match 'sessions/forgot',  to: 'sessions#forgot', via: [:get, :post], as: :sessions_forgot
    get 'sessions/reset/:user_id/:token', to: 'sessions#reset_password', as: :reset_password
    resources :sessions
    get 'remove_vicarious_login', to: 'application#remove_vicarious_login'
    get 'login_as_student', to: 'application#force_login_as_student', as: :login_as_student
    # RSVP for events
    get 'rsvp/event/:id', to: 'rsvp#event', as: :rsvp_event
    get 'rsvp/attend/:id', to: 'rsvp#attend', as: :rsvp_attend
    get 'rsvp/unattend/:id', to: 'rsvp#unattend', as: :rsvp_unattend
    get 'rsvp', to: 'rsvp#index'

    # Online Applications
    get 'apply/:offering/', to: 'apply#index', constraints: { offering: /\d+/ }, as: :apply
    match 'apply/:offering/which', to: 'apply#which', constraints: { offering: /\d+/ }, via: [:get, :post], as: :apply_which
    match 'apply/:offering/page/:page', to: 'apply#page', constraints: { offering: /\d+/ }, via: [:get, :post, :put, :patch], as: :apply_page
    match 'apply/:offering/update/:page', to: 'apply#update', constraints: { offering: /\d+/ }, via: [:get, :post, :put, :patch]
    match 'apply/:offering/cancel', to: 'apply#cancel', constraints: { offering: /\d+/ }, via: [:get, :post, :put, :patch]
    match 'apply/:offering/enter_code', to: 'apply#enter_code', constraints: { offering: /\d+/ }, via: [:get, :post, :put, :patch]
    get 'apply/:offering/cancelled', to: 'apply#cancelled', constraints: { offering: /\d+/ }
    get 'apply/:offering/help/:id', to: 'apply#help', as: :apply_help
    get 'apply/:offering/review', to: 'apply#review', constraints: { offering: /\d+/ }
    match 'apply/:offering/submit', to: 'apply#submit', constraints: { offering: /\d+/ }, via: [:post, :put, :patch]
    match 'apply/:offering/files/application_file/file/:id/:filename', to: 'apply#file', via: [:get], as: :apply_file
    get 'apply/:offering/group_member', to: 'apply#group_member', constraints: { offering: /\d+/ }
    match 'apply/:offering/revise_abstract', to: 'apply#revise_abstract', via: [:get, :post, :put, :patch], as: :apply_revise_abstract
    match 'apply/:offering/validate/:group_member_id/:token', to: 'apply#group_member_validation', as: :apply_group_member_validation, via: [:get, :post, :put, :patch]
    #match.apply_confirmation_guests 'apply/:offering/confirmation/guests/:action/:id', :controller => 'apply/confirmation/guests'
    get 'apply/:offering/confirmation/', to: 'apply/confirmation#index', as: :apply_confirmation
    match 'apply/:offering/confirmation/', to: 'apply/confirmation#confirm', via: [:get, :patch]
    match 'apply/:offering/confirmation/contact_info', to: 'apply/confirmation#contact_info', via: [:get, :patch]
    match 'apply/:offering/confirmation/workshops', to: 'apply/confirmation#workshops', via: [:get, :patch]
    match 'apply/:offering/confirmation/nominate', to: 'apply/confirmation#nominate', via: [:get, :patch]
    match 'apply/:offering/confirmation/theme', to: 'apply/confirmation#theme', via: [:get, :patch]
    match 'apply/:offering/confirmation/requests', to: 'apply/confirmation#requests', via: [:get, :patch]

    # Mentor
    get 'mentor', to: 'mentor#index'
    get 'mentor/map/:mentor_id/:token', to: 'mentor#map', as: :mentor_map
    get 'mentor/offering/:offering_id/map/:mentor_id/:token', to: 'mentor#map', as: :mentor_offering_map
    get 'mentor/offering/:offering_id', to: 'mentor#index', as: :mentor_offering
    match 'mentor/update', to: 'mentor#update', via: [:get, :post, :put, :patch]
    match 'mentor/mentee/:id', to: 'mentor#mentee', via: [:get, :post, :put, :patch], as: :mentee
    match 'mentor/offering/:offering_id/mentee_abstract_approve/:id', to: 'mentor#mentee_abstract_approve', via: [:get, :post, :put, :patch]
    match 'mentor/mentee_abstract_approve/:id', to: 'mentor#mentee_abstract_approve', via: [:get, :post, :put, :patch], as: :mentee_abstract_approve
    get 'mentor/:id/letter/:filename', to: 'mentor#letter', as: :mentor_letter

    # Committee Members
    get 'committee_member/map/:committee_member_id/:token', to: 'committee_member#map', as: :committee_member_map

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

    # Service Learning | Community Engaged Course
    # Name change from service_learning to community_engaged
    match 'community_engaged', to: 'service_learning#index', via: [:get, :post], :quarter_abbrev => 'current', as: :community_engaged
    get 'community_engaged/which', to: 'service_learning#which', :quarter_abbrev => 'current'
    get 'community_engaged/my_position', to: 'service_learning#my_position', :quarter_abbrev => 'current'
    get 'community_engaged/position/:id', to: 'service_learning#position', :quarter_abbrev => 'current'
    get 'community_engaged/choose/:id', to: 'service_learning#choose', :quarter_abbrev => 'current'
    get 'community_engaged/complete', to: 'service_learning#complete', :quarter_abbrev => 'current'
    match 'community_engaged/change/:id', to: 'service_learning#change', via: [:get, :post, :put, :patch], :quarter_abbrev => 'current'
    match 'community_engaged/contact/:id', to: 'service_learning#contact', via: [:get, :post, :put, :patch], :quarter_abbrev => 'current'
    match 'community_engaged/risk/:id', to: 'service_learning#risk', via: [:get, :post, :put, :patch], :quarter_abbrev => 'current'

    # Sidekiq admin routes
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # Protect against timing attacks:
      # - See https://codahale.com/a-lesson-in-timing-attacks/
      # - See https://thisdata.com/blog/timing-attacks-against-string-comparison/
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use digests to stop length information leaking (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USERNAME"])) &
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"]))
    end if Rails.env.production?
    mount Sidekiq::Web, at: '/admin/sidekiq'

  end
  
  # Redirect to Sub URI only when it doesn't match '/expo/' in the request URLs
  constraints ->(req) { !req.url.match('/expo/') } do
      get "/*all", to: redirect{|params, request| "/expo/#{params[:all]}"}
  end

end
