ActiveAdmin.register Organization do
  actions :all, :except => [:destroy]
  batch_action :destroy, false
  config.per_page = [30, 50, 100, 200]
  config.sort_order = 'name_asc'
  menu parent: 'Tools'
  
  permit_params :name, :parent_organization_id, :mailing_line_1, :mailing_line_2, :mailing_city, :mailing_city, :website_url, :main_phone, :mission_statement, :approved, :inactive, :does_service_learning, :does_pipeline, :target_school, :next_active_quarter_id, :school_type_id, :multiple_quarter
  
  index do
    id_column
    column :name, sortable: :name do |resource| 
       editable_text_column resource, "organization", :name, true, false
     end
    # column ('Name') {|org| link_to org.name, admin_organization_path(org)}
    column ('Approved') {|org| org.approved  }
    column ('Archived') {|org| org.archive if org.archive }
    actions
  end
  
  show do
    attributes_table do
       row :name
       row :mailing_line_1
       row :mailing_line_2
       row :mailing_city
       row :mailing_state
       row :mailing_zip
       row :website_url
       row :main_phone
       row :mission_statement
       row :approved
       row ('Archived'){|org| org.archive}
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name, required: true      
      f.input :parent_organization_id, as: :select, collection: Organization.all.reject{|o| o.id==organization.id}.sort.map{|o| [o.name, o.id]}, :input_html => { :class => 'chosen-select' }, include_blank: "(None)"            
      f.input :mailing_line_1, label: 'Mailing address line 1'
      f.input :mailing_line_2, label: 'Mailing address line 2'
      f.input :mailing_city, label: 'City'
      #f.input :mailing_state, as: :state
      f.input :mailing_zip, label: 'Zipcode'
      f.input :website_url, label: 'Website'
      f.input :main_phone, label: 'Main phone'
      f.input :mission_statement, as: :text, :input_html => { :rows => 8, :style => 'width:100%' }
    end
    f.actions
  end  
  
  filter :name, as: :string
  
end