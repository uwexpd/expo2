ActiveAdmin.register User do  
  actions :all, :except => [:new, :destroy]
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu parent: 'Groups'
  
  permit_params :admin

  before_action -> { check_permission("user_manager") }

  member_action :session_history, :method => :get do
    @requests = SessionHistory.where("session_id = ? ", params[:id]).order(:created_at)
    @start_time = @requests.first.created_at
    @user = LoginHistory.find_by_session_id(params[:id]).user
  end  
    
  index pagination_total: false do  
    column 'Username' do |user|
      span link_to(user.login, admin_user_path(user))
      span "@u" if user.is_a? PubcookieUser
    end
    column '' do |user|
      status_tag 'admin', class: 'admin small' if user.admin?
    end
    column 'Type' do |user|
      user.identity_type || "Standard User"
    end
    column 'Person' do |user|
      link_to user.person.fullname, admin_person_path(user.person), :target => '_blank' rescue nil
    end
    column 'Last Login' do |user|
      "#{time_ago_in_words user.logins.last.created_at} ago" rescue "never"
    end    
    actions
  end
    
  show do
    panel '' do
      div :class => 'content-block' do
        h1 "User: #{user.login}" do
          span '(PubCookies User)', :class => 'light small' if user.is_a? PubcookieUser
          status_tag 'admin', class: 'admin small' if user.admin?
        end
        div do
          "Email: " + user.email
        end
        span :class => 'light small' do
          "Created #{user.created_at.to_s(:short_at_time12)} #{' by ' + user.creator.firstname_first rescue nil}"  "#{' | Last edited ' + user.updated_at.to_s(:short_at_time12)}" + "#{' by ' + user.updater.firstname_first rescue nil}"
        end
        span link_to '← Back to Users', admin_users_path
      end
    end

    div :class => 'tabsview' do
      tabs do
          tab "Units & Roles (#{user.roles.size})" do
            panel '' do
              table_for user.roles.order('unit_id ASC') do
                column ('Unit') {|role| role.unit ? role.unit.name : 'Global' }
                column ('Role') {|role| role.name }
                #column ('functions') {|role| link_to 'Remove', user_role_path(user, role), remote: true }              
              end
            end
          end
          tab "Logins (#{user.logins.size})" do
            panel '' do
              paginated_collection(user.logins.page(params[:page]).per(20).order('id DESC'), download_links: false) do
                table_for(collection, sortable: false) do
                    column ('Type') {|login| status_tag 'Sucessful Login', class: 'ok small' }
                    column ('Date/Time') {|login| time_ago_in_words(login.created_at) }
                    column ('Source IP') do |login| 
                      span login.ip
                      span 'on campus', class: 'outline tag' if login.on_campus?
                    end 
                    column ('Session History') {|login| link_to "Session History", session_history_admin_user_path(login.session_id) unless login.session_histories.empty?}                   
                end 
              end
            end
          end
      end
    end
  end  

  sidebar "Search Username", only: :show do  
      render "search_user"
  end
  
  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Edit #{user.login}" do
      f.input :email, as: :string
      f.input :admin, label: 'User can access admin aera', as: :boolean
    end
    f.actions do
       f.action(:submit)
       f.cancel_link(admin_user_path(user))
     end
  end
  
  filter :login, label: 'Username',  as: :string
  filter :email, label: 'Email (only for non-uw users)', as: :string
  
end
