ActiveAdmin.register EventType do  
  batch_action :destroy, false
  config.sort_order = 'title'  
  menu parent: 'Tools'
  
  
  permit_params :title, :description
  
  index do
     column ('Title') {|event_type| link_to event_type.title, admin_event_type_path(event_type) }
     column :description
     actions
  end   
   
  show do
    attributes_table do
      row :title
      row :description 
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do  
      f.input :title, :input_html => { :style => 'width:50%;' }
      f.input :description, :input_html => { :rows => 3, :style => 'width:50%;' }
    end
    f.actions
  end
   
  filter :title
  
end