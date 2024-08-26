ActiveAdmin.register User do
  actions :all, :except => [:new, :destroy]
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu parent: 'Groups', label: "<i class='mi padding_right'>account_circle</i> Users".html_safe
  
  permit_params :admin, :email, :picture, roles_attributes: [:role_id, :unit_id, :_destroy, :id]

  before_action -> { check_permission("user_manager") }

  scope :all
  scope :admin

  member_action :session_history, :method => :get do
    @requests = SessionHistory.where("session_id = ? ", params[:id]).order(:created_at)
    @start_time = @requests.first.created_at
    @user = LoginHistory.find_by_session_id(params[:id]).user
  end  
    
  index pagination_total: false do  
    column 'Username' do |user|
      span link_to(highlight(user.login,params.dig(:q, :login_contains)), admin_user_path(user))
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
    if params[:scope] == 'admin'
      column :roles do |user|
        user.roles.map { |role| "#{ role.unit.name rescue 'Global'}: #{role.name}" }.join('<br> ').html_safe
      end
    end
    column 'Last Login' do |user|
      "#{time_ago_in_words user.logins.last.created_at} ago" rescue "never"
    end    
    actions
  end
    
  show do
    div class: 'panel panel_contents' do
        # if user.picture.attached?
        #   span class: "left", style: "margin-right: 1rem;" do
        #     image_tag url_for(user.picture), size: "100x100"
        #   end
        # end
        h2 "User: #{user.login}" do
          span '(PubCookies User)', :class => 'light small' if user.is_a? PubcookieUser
          status_tag 'admin', class: 'admin small' if user.admin?
        end

        div class: 'content-block' do
          "Email: " + user.email
          span :class => 'light small' do
            "Created #{user.created_at.to_s(:short_at_time12)} #{' by ' + user.creator.firstname_first rescue nil}"  "#{' | Last edited ' + user.updated_at.to_s(:short_at_time12)}" + "#{' by ' + user.updater.firstname_first rescue nil}"
          end
          span link_to '← Back to Users', admin_users_path
        end
    end

    div :class => 'tabsview' do
      tabs do
          tab "Units & Roles (#{user.roles.size})", id: 'unit_roles' do
            panel '' do
              div class: 'right padding_right' do
                link_to "Assign new role", edit_admin_user_path(user), class: 'button small'
              end
              table_for user.roles.order('unit_id ASC') do
                column ('Unit') {|role| role.unit ? role.unit.name : 'Global' }
                column ('Role') {|role| role.name }
                #column ('functions') {|role| link_to 'Remove', user_role_path(user, role), remote: true }              
              end
            end
          end
          tab "Logins (#{user.logins.size})", id: 'logins' do
            panel '' do
              paginated_collection(user.logins.page(params[:page]).per(15).order('id DESC'), params: {anchor: 'logins' }, download_links: false) do
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

  sidebar "Search User", only: :show do
      render "search_user"
  end
  
  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs "Edit #{user.login}" do
      f.input :email, as: :string
      f.input :admin, label: 'User can access admin aera', as: :boolean      
      f.input :picture, as: :file      
    end   

    f.inputs 'User roles' do
      hr      
        f.has_many :roles, allow_destroy: true, heading: false do |role|
          role.input :role_id, as: :select, collection: [["[User]", nil]] + Role.all.map{|r| [r.title, r.id]}, include_blank: "[User]", prompt: "-- Select a Role --"
          role.input :unit_id, as: :select, collection: [["[Global]", nil]] + Unit.all.map{|u| [u.name, u.id]}, prompt: "-- Select a Unit --"
        end      
    end
    
    f.actions do
       f.action(:submit)
       f.cancel_link(admin_user_path(user))
     end
  end
  
  filter :login, label: 'Username',  as: :string
  filter :email, label: 'Email (only for non-uw users)', as: :string
  # filter :units, as: :select, collection: Unit.all.pluck(:name, :id) [TODO] Make it display only one username.
  
end
