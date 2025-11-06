ActiveAdmin.register Unit do
  config.filters = false
  batch_action :destroy, false
  config.sort_order = 'name_asc'
  menu parent: 'Groups', label: "<i class='mi padding_right'>apartment</i> Units".html_safe

  before_action -> { check_permission("unit_manager") }
  
  permit_params :name, :abbreviation, :logo_uri, :description, :home_url, :engage_url, :show_on_expo_welcome, :phone, :email, :short_title
  
  # Completely replace the record retrieving code (e.g., you have a custom to_param implementation in your models), override the resource method on the controller:
  controller do
    def find_resource
      scoped_collection.where(abbreviation: params[:id]).first! if params[:id]
    end
  end

  index do
    column 'Unit', sortable: :name do |unit|
      link_to unit.name, admin_unit_path(unit)
    end    
    column :short_title
    column :description
    column :email
    column :phone
    actions
  end
  
  show do
    attributes_table do
        row :name
        row :short_title
        row :abbreviation
        row :description        
        row :home_url
        row :engage_url
        row :show_on_expo_welcome
        row :show_on_equipment_reservation
        # row :logo do |image|
        #           image_tag logo_url
        #         end
    end
    
    panel "Users & Roles (#{unit.users.distinct.count})", only: :show do
      div :class => 'content-block' do
        if unit.users.any?
          table_for unit.users.distinct.order(:login) do
            column 'Username' do |user|
              div do
                span link_to user.login, admin_user_path(user)
                span "@u", class: 'light' if user.is_a?(PubcookieUser)
                status_tag 'admin', class: 'admin tag small' if user.admin?
              end
            end
            column 'Person' do |user|
              link_to user.person.fullname, admin_person_path(user.person), target: '_blank' rescue nil
            end
            column 'Roles' do |user|
              unit_roles = user.roles.for(unit.id).to_a
              global_roles = user.roles.for(nil).to_a
              roles = (unit_roles + global_roles).select { |r| !r.role_id.nil? }.uniq
              if roles.any?
                ul class: 'bulletless', style: 'margin-left: -3em;' do
                  roles.each do |role|
                    li do
                      span role.name
                      span "(Global)", class: 'light small' if role.unit_id.nil?
                    end
                  end
                end
              # else
              #   span 'No roles assigned', class: 'small light'
              end
            end
            column 'Functions' do |user|            
                span link_to '<span class="mi">visibility</span>'.html_safe, admin_user_path(user), class: 'action_icon'
                span link_to '<span class="mi">edit</span>'.html_safe, edit_admin_user_path(user), class: 'action_icon'            
            end
          end
        else
          para "No users assigned to this unit.", class: 'light'
        end
      end
    end
  end
  
  sidebar "Last updated at", only: :show do
    attributes_table do
      row :phone
      row :email
      row :updated_at
      row ('Updated by') {|r| link_to r.updater.firstname_first, admin_user_path(r.updater) rescue nil}
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    inputs "#{unit.name}" do
      input :name
      if f.object.new_record?
        input :abbreviation
      end
      input :short_title, hint: "Display the short description in the system."
      input :description, :input_html => { :rows => 5, :style => "width:100%;" }
      input :phone
      input :email
      input :home_url
      input :engage_url
      input :show_on_expo_welcome, as: :boolean
      input :show_on_equipment_reservation, as: :boolean
    end
    actions
  end
  
end