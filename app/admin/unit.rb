ActiveAdmin.register Unit do
  config.filters = false
  batch_action :destroy, false
  config.sort_order = 'name_asc'
  menu parent: 'Groups'

  before_action -> { check_permission("unit_manager") }
  
  permit_params :name, :abbreviation, :logo_uri, :description, :home_url, :engage_url, :show_on_expo_welcome, :phone, :email
  
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
    column :description
    column :email
    column :phone
    actions
  end
  
  show do
    attributes_table do
        row :name
        row :abbreviation
        row :description
        row :phone
        row :email
        row :home_url
        row :engage_url
        row :show_on_expo_welcome
        row :show_on_equipment_reservation
        # row :logo do |image|
        #           image_tag logo_url
        #         end
    end
  end
  
  sidebar "Last updated at", only: :show do
    attributes_table do
      row :updated_at
      row :updater_id
      # row ('At') {|r|r.updated_at}
      #       row ('By') {|r|r.updater_id}
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    inputs "#{unit.name}" do
      input :name
      if f.object.new_record?
        input :abbreviation
      end
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