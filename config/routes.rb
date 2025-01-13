require 'sidekiq/web'
Rails.application.routes.draw do
  
  root to: redirect('expo'), :as => 'redirect_root'
  get '/auth/:provider/callback', to: 'sessions#create'

  scope 'expo' do

    root 'welcome#index'    
    # -------------------------------------------------------------------------------------------
    # Custom Active Admin Routes
    # -------------------------------------------------------------------------------------------
    get 'admin', to: 'admin/dashboard#index', as: :admin
    get 'files/user/:id/:mounted_as/:filename', to: 'admin/user#picture'
    # Admin Apply Actions
    match 'admin/apply/dean_approve', to: 'admin/apply#dean_approve', as: :admin_apply_dean_approve, via: [:get, :post, :put]
    match 'admin/apply/finaid_approve', to: 'admin/apply#finaid_approve', as: :admin_apply_finaid_approve, via: [:get, :post, :put]
    match 'admin/apply/disberse', to: 'admin/apply#disberse', as: :admin_apply_disberse, via: [:get, :post, :put]
    get 'admin/apply/:offering', to: 'admin/apply#manage', as: :admin_apply_manage
    get 'admin/apply/:offering/list', to: 'admin/apply#list', as: :admin_apply_list
    get 'admin/apply/:offering/awardees', to: 'admin/apply#awardees', as: :admin_apply_awardees
    get 'admin/apply/:offering/awardees/mentors', to: 'admin/apply#mentors', as: :admin_apply_awardees_mentors
    match 'admin/apply/:offering/scored_selection', to: 'admin/apply#scored_selection', as: :admin_apply_scored_selection, via: [:get, :post, :put]
    get 'admin/apply/:offering/invited_guests', to: 'admin/apply#invited_guests', as: :admin_apply_invited_guests
    get 'admin/apply/:offering/nominated_mentors', to: 'admin/apply#nominated_mentors', as: :admin_apply_nominated_mentors
    get 'admin/apply/:offering/theme_responses', to: 'admin/apply#theme_responses', as: :admin_apply_theme_responses
    get 'admin/apply/:offering/proceedings_requests', to: 'admin/apply#proceedings_requests', as: :admin_apply_proceedings_requests
    get 'admin/apply/:offering/special_requests', to: 'admin/apply#special_requests', as: :admin_apply_special_requests
    get 'admin/apply/:offering/phases/:id', to: 'admin/apply#phase', as: :admin_apply_phase
    post 'admin/apply/:offering/phases/:id', to: 'admin/apply#switch_to', as: :admin_apply_phase_switch
    get 'admin/apply/:offering/phases/:phase/tasks/:id', to: 'admin/apply#task', as: :admin_apply_phase_task
    match 'admin/apply/:offering/phases/:phase/tasks/mass_update', to: 'admin/apply#mass_update', as: :admin_apply_phase_task_mass_update, via: [:get, :post]
    post 'admin/apply/:offering/phases/:phase/tasks/:id/assign_reviewer', to: 'admin/apply#mass_assign_reviewers', as: :admin_apply_assign_reviewer
    post 'admin/apply/:offering/phases/:phase/tasks/:id/change_status', to: 'admin/apply#mass_status_change', as: :admin_apply_change_status
    post 'admin/apply/:offering/phases/:phase/tasks/:id/send_reviewer_invite', to: 'admin/apply#send_reviewer_invite_emails', as: :admin_apply_send_reviewer_invite
    post 'admin/apply/:offering/phases/:phase/tasks/:id/send_interviewer_invite_emails', to: 'admin/apply#send_interviewer_invite_emails', as: :admin_apply_send_interviewer_invite_emails
    post 'admin/apply/:offering/phases/:phase/tasks/:id/assign_review_decision', to: 'admin/apply#assign_review_decision', as: :admin_apply_assign_review_decision
    post 'admin/apply/:offering/phases/:phase/tasks/:id/add_interview', to: 'admin/apply#add_interview', as: :admin_apply_add_interview
    get 'admin/apply/:offering/phases/:phase/tasks/:id/interview/:interview/edit', to: 'admin/apply#edit_interview', as: :admin_apply_edit_interview
    patch 'admin/apply/:offering/phases/:phase/tasks/:id/update/:interview', to: 'admin/apply#update_interview', as: :admin_apply_update_interview
    delete 'admin/apply/:offering/phases/:phase/tasks/:id/remove_interview/:interview', to: 'admin/apply#remove_interview', as: :admin_apply_remove_interview
    post 'admin/apply/:offering/phases/:phase/tasks/:id/new_interview_timeblock', to: 'admin/apply#new_interview_timeblock', as: :admin_apply_new_interview_timeblock
    post 'admin/apply/:offering/phases/:phase/tasks/:id/remove_interview_timeblock/:time',to: 'admin/apply#remove_interview_timeblock', as: :admin_apply_remove_interview_timeblock
    get 'admin/apply/:offering/phases/:phase/tasks/:id/mini_details', to: 'admin/apply#mini_details', as: :admin_apply_mini_details
    match 'admin/apply/:offering/phases/:phase/tasks/:id/notify_dean', to: 'admin/apply#notify_dean', as: :admin_apply_notify_dean, via: [:get, :post, :put]
    match 'admin/apply/:offering/phases/:phase/tasks/:id/send_to_financial_aid', to: 'admin/apply#send_to_financial_aid', as: :admin_apply_send_to_financial_aid, via: [:get, :post, :put]
    # Admin Apply Files   
    get 'admin/apply/:offering/files/application_file/file/:id/:file', to: 'admin/apply#view', as: :admin_apply_file
    get 'admin/apply/:offering/files/application_mentor/letter/:id/:mentor', to: 'admin/apply#view', as: :admin_apply_letter    
    # End of Admin Apply

    post 'admin/offerings/:offering_id/applications/:id/composite_report', to: 'admin/applications#composite_report'
    post 'admin/applications/:id/composite_report', to: 'admin/applications#composite_report'
    post 'admin/base/vicarious_login', to: 'admin/base#vicarious_login', as: :admin_vicarious_login
    get 'admin/base/remove_vicarious_login', to: 'admin/base#remove_vicarious_login', as: :admin_remove_vicarious_login
    get 'admin/application_for_offerings', to: 'admin/applications#index'
    get 'admin/application_mentors', to: 'admin/mentors#index'
    get 'admin/service_learning_placements', to: 'admin/dashboard#index' # [TODO] update when SLP is ready
    match 'admin/communicate/email/write', to: 'admin/email#write', as: :admin_email_write, via: [:get, :post]
    post 'admin/communicate/email/queue', to: 'admin/email#queue', as: :admin_queue_email
    get 'admin/communicate/email/apply_template', to: 'admin/email#apply_template'    
    match 'admin/communicate/email/sample_preview', to: 'admin/email#sample_preview', via: [:get, :post], as: :admin_email_sample_preview
    match 'admin/communicate/email/resample', to: 'admin/email#resample_placeholder_codes', via: [:get, :post], as: :admin_email_resample
    get 'invitees/event/:event_id', to: 'admin/invitees#index', as: 'admin_invitees_event'
    post 'admin/queries/:id/refresh_dropdowns', to: 'admin/queries#refresh_dropdowns', as: 'admin_query_refresh_dropdowns'

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
        resources :sessions
      end
      resources :contact_histories
      resources :committees do
        resources :members
        resources :quarters
        resources :meetings
      end      
      resources :notes
      resources :service_learning_positions
      resources :quarter
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
    match 'sessions/reset/:user_id/:token', to: 'sessions#reset_password', as: :reset_password, via: [:get, :post]
    resources :sessions
    get 'remove_vicarious_login', to: 'application#remove_vicarious_login'
    get 'login_as_student', to: 'application#force_login_as_student', as: :login_as_student    

    # RSVP for events    
    get 'rsvp/event/:id', to: 'rsvp#event', as: :rsvp_event
    post 'rsvp/attend/:id', to: 'rsvp#attend', as: :rsvp_attend
    delete 'rsvp/unattend/:id', to: 'rsvp#unattend', as: :rsvp_unattend
    get 'rsvp', to: 'rsvp#index', as: :rsvp

    # Online Applications
    get 'apply', to: "apply#list", as: :apply_list
    get 'apply/:offering/', to: 'apply#index', constraints: { offering: /\d+/ }, as: :apply
    match 'apply/:offering/which', to: 'apply#which', constraints: { offering: /\d+/ }, via: [:get, :post], as: :apply_which
    match 'apply/:offering/page/:page', to: 'apply#page', constraints: { offering: /\d+/ }, via: [:get, :post, :put, :patch], as: :apply_page
    match 'apply/:offering/update/:page', to: 'apply#update', constraints: { offering: /\d+/ }, via: [:get, :post, :put, :patch]
    match 'apply/:offering/cancel', to: 'apply#cancel', constraints: { offering: /\d+/ }, via: [:get, :post, :put, :patch]
    match 'apply/:offering/enter_code', to: 'apply#enter_code', constraints: { offering: /\d+/ }, via: [:get, :post, :put, :patch], as: :apply_enter_code
    match 'apply/:offering/accept', to: 'apply#accept', constraints: { offering: /\d+/ }, via: [:get, :post, :put, :patch]
    get 'apply/:offering/cancelled', to: 'apply#cancelled', constraints: { offering: /\d+/ }
    get 'apply/:offering/help/:id', to: 'apply#help', as: :apply_help
    get 'apply/:offering/review', to: 'apply#review', constraints: { offering: /\d+/ }
    match 'apply/:offering/submit', to: 'apply#submit', constraints: { offering: /\d+/ }, via: [:post, :put, :patch]
    get 'apply/:offering/files/application_file/file/:id/:filename', to: 'apply#file', as: :apply_file
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
    match 'apply/:offering/confirmation/time_conflicts', to: 'apply/confirmation#time_conflicts', via: [:get, :patch]
    match 'apply/:offering/confirmation/requests', to: 'apply/confirmation#requests', via: [:get, :patch]
    #Online Proceedings/Schedules
    get 'apply/:offering/proceedings', to: 'apply/proceedings#index', as: :apply_proceedings
    get 'apply/:offering/proceedings/offering_session/:id', to: 'apply/proceedings#offering_session', as: :apply_proceedings_offering_session
    get 'apply/:offering/proceedings/result', to: 'apply/proceedings#result', as: :apply_proceedings_result

    # Mentor
    get 'mentor', to: 'mentor#index', as: :mentor
    get 'mentor/map/:mentor_id/:token', to: 'mentor#map', as: :mentor_map
    get 'mentor/offering/:offering_id/map/:mentor_id/:token', to: 'mentor#map', as: :mentor_offering_map
    get 'mentor/offering/:offering_id', to: 'mentor#index', as: :mentor_offering
    match 'mentor/update', to: 'mentor#update', via: [:get, :post, :put, :patch]
    match 'mentor/mentee/:id', to: 'mentor#mentee', via: [:get, :post, :put, :patch], as: :mentee
    match 'mentor/offering/:offering_id/mentee_abstract_approve/:id', to: 'mentor#mentee_abstract_approve', via: [:get, :post, :put, :patch]
    match 'mentor/mentee_abstract_approve/:id', to: 'mentor#mentee_abstract_approve', via: [:get, :post, :put, :patch], as: :mentee_abstract_approve
    get 'mentor/:id/letter/:filename', to: 'mentor#letter', as: :mentor_letter

    # Committee Members
    get 'committee_member', to: 'committee_member#index', as: :committee_member
    match 'committee_member/which', to: 'committee_member#which', via: [:get, :post]
    match 'committee_member/availability', to: 'committee_member#availability', via: [:get, :post, :put, :patch], as: :committee_member_availability
    match 'committee_member/specialty', to: 'committee_member#specialty', via: [:get, :post, :put, :patch], as: :committee_member_specialty
    match 'committee_member/meetings', to: 'committee_member#meetings', via: [:get, :post, :put, :patch], as: :committee_member_meetings
    get 'committee_member/complete', to: 'committee_member#complete', as: :committee_member_complete
    get 'committee_member/profile', to: 'committee_member#profile'
    get 'committee_member/map/:committee_member_id/:token', to: 'committee_member#map', as: :committee_member_map

    # Interviewer
    get 'interviewer/:offering', to: 'interviewer#index', as: :interviewer
    get 'interviewer/:offering/show/:id', to: 'interviewer#show'
    post 'interviewer/:offering/show/:id/composite_report', to: 'interviewer#composite_report', as: :interviewer_composite_report
    get 'interviewer/:offering/view/:id', to: 'interviewer#view'
    get 'interviewer/:offering/transcript/:id', to: 'interviewer#transcript'
    post 'interviewer/:offering/finalize', to: 'interviewer#finalize'
    post 'interviewer/:offering/multi_composite_report', to: 'interviewer#multi_composite_report'
    get 'interviewer/:offering/criteria', to: 'interviewer#criteria', as: :interviewer_criteria
    get 'interviewer/:offering/inactive/', to: 'interviewer#inactive'
    match 'interviewer/:offering/update/:id', to: 'interviewer#update', via: [:post, :put, :patch]    
    match 'interviewer/:offering/weclome/:committee', to: 'interviewer#welcome', as: :offering_interviewer, via: [:get, :post, :put, :patch]
    match 'interviewer/:offering/availability/:committee', to: 'interviewer#interview_availability', as: :interviewer_availability, via: [:get, :post, :put, :patch]
    get 'interviewer/:offering/not_this_quarter/:committee', to: 'interviewer#not_this_quarter'
    get 'interviewer/:offering/inactive/:committee', to: 'interviewer#inactive'
    match 'interviewer/:offering/mark_available', to: 'interviewer#mark_available', via: [:get, :patch]
    match 'interviewer/:offering/mark_unavailable', to: 'interviewer#mark_unavailable', via: [:get, :patch]
    get 'interviewer/:offering/committee', to: 'interviewer/committee#index', as: :interview_committee
    get 'interviewer/:offering/committee/show/:id', to: 'interviewer/committee#show', as: :interview_committee_show
    get 'interviewer/:offering/committee/criteria', to: 'interviewer/committee#criteria'
    post 'interviewer/:offering/committee/finalize', to: 'interviewer/committee#finalize'
    match 'interviewer/:offering/committee/update/:id', to: 'interviewer/committee#update', via: [:post, :put, :patch]

    # Reviewer
    get 'reviewer/:offering', to: 'reviewer#index', as: :reviewer
    get 'reviewer/:offering/show/:id', to: 'reviewer#show'
    get 'reviewer/:offering/show/:id/view', to: 'reviewer#view', as: :reviewer_view_file
    post 'reviewer/:offering/show/:id/composite_report', to: 'reviewer#composite_report', as: :reviwer_composite_report
    get 'reviewer/:offering/view/:id', to: 'reviewer#view'
    get 'reviewer/:offering/transcript/:id', to: 'reviewer#transcript'
    post 'reviewer/:offering/finalize', to: 'reviewer#finalize'
    post 'reviewer/:offering/multi_composite_report', to: 'reviewer#multi_composite_report'
    get 'reviewer/:offering/criteria', to: 'reviewer#criteria', as: :reviewer_criteria
    get 'reviewer/:offering/extra_instructions', to: 'reviewer#extra_instructions'    
    match 'reviewer/:offering/update/:id', to: 'reviewer#update', via: [:post, :put, :patch]
    get 'reviewer/:offering/committee', to: 'reviewer/committee#index', as: :review_committee
    get 'reviewer/:offering/committee/show/:id', to: 'reviewer/committee#show', as: :review_committee_show
    get 'reviewer/:offering/committee/criteria', to: 'reviewer/committee#criteria'
    post 'reviewer/:offering/committee/finalize', to: 'reviewer/committee#finalize'
    match 'reviewer/:offering/committee/update/:id', to: 'reviewer/committee#update', via: [:post, :put, :patch]

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
