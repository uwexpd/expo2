ActiveAdmin.register ResearchArea do
  batch_action :destroy, false
  config.sort_order = 'name_asc'
  config.per_page = [30, 50, 100, 200]
  menu parent: 'Tools'

  permit_params :name
  
  index do
     id_column
     column :name, sortable: :name do |resource| 
       editable_text_column resource, "research_area", :name, true, false
     end
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