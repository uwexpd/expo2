ActiveAdmin.register ResearchArea do
  batch_action :destroy, false
  config.sort_order = 'name_asc'
  menu parent: 'Tools'

  permit_params :name
  
  index do
     column ('Name') {|area| link_to area.name, admin_research_area_path(area)}     
     actions
  end   
   
  show do
    attributes_table do
      row :name     
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do  
      f.input :name, :input_html => { :style => 'width:50%;' }      
    end
    f.actions
  end
   
  filter :name

end