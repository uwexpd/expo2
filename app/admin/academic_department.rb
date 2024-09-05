ActiveAdmin.register AcademicDepartment do  
  batch_action :destroy, false
  config.sort_order = 'name'
  config.per_page = [30, 50, 100, 200]
  menu parent: 'Tools'
  
  
  permit_params :name, :description
  
  index do
     id_column
     column :name, sortable: :name do |resource| 
       editable_text_column resource, "academic_department", :name, true, false
     end
     column :description do |resource| 
       editable_text_column resource, "academic_department", :description, false, false
     end     
     actions
  end   
   
  show do
    attributes_table do
      row :name
      row :description 
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do  
      f.input :name, :input_html => { :style => 'width:50%;' }
      f.input :description, :input_html => { :rows => 3, :style => 'width:50%;' }
    end
    f.actions
  end
   
  filter :name
  
end