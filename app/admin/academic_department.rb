ActiveAdmin.register AcademicDepartment do  
  batch_action :destroy, false
  config.sort_order = 'name'
  menu parent: 'Tools'
  
  
  permit_params :name, :description
  
  index do
     column ('Name') {|dept| link_to dept.name, admin_academic_department_path(dept)}
     column ('Description') {|dept| dept.description }
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