ActiveAdmin.register DepartmentExtra do  
  batch_action :destroy, false
  config.sort_order = 'fixed_name_asc'  
  config.per_page = [30, 50, 100, 200]
  menu parent: 'Tools'
  
  
  permit_params :fixed_name, :chair_name, :chair_email, :chair_title
  
  index do         
     column (:id) {|dept_extra| link_to dept_extra.id, admin_department_extra_path(dept_extra)}
     column ("SDB Department Name"){|dept_extra| dept_extra.department.dept_full_nm.strip.titleize.gsub("Of", "of") if dept_extra.dept_code}
     column :fixed_name, sortable: :name do |resource| 
       editable_text_column resource, "department_extras", :fixed_name, true
     end     
     column ("College Name"){|dept_extra| dept_extra.college.full_name if dept_extra.dept_code}
     # column ("College Campus"){|dept_extra| dept_extra.college.campus_name}
     column :chair_name do |resource| 
       editable_text_column resource, "department_extras", :chair_name, false
     end
     # column :chair_email do |resource| 
     #   editable_text_column resource, "department_extras", :chair_email, false
     # end
     # column :chair_title do |resource| 
     #   editable_text_column resource, "department_extras", :chair_title, false
     # end
     actions
  end   
   
  show do
    attributes_table do
      row :dept_code
      row ("SDB Department Name"){|dept_extra| dept_extra.department.dept_full_nm.strip.titleize.gsub("Of", "of") if dept_extra.dept_code}
      row :fixed_name
      row ("College Name"){|dept_extra| dept_extra.college.full_name if dept_extra.dept_code}
      row ("College Campus"){|dept_extra| dept_extra.college.campus_name if dept_extra.dept_code}
      row :chair_name
      row :chair_email
      row :chair_title
      row :updated_at      
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do  
      f.input :fixed_name, :input_html => { :style => 'width:50%;' }, hint: 'Leave blank if same as SDB department name' 
      f.input :chair_name, :input_html => { :style => 'width:50%;' }
      f.input :chair_email, :input_html => { :style => 'width:50%;' }
      f.input :chair_title, :input_html => { :style => 'width:50%;' }      
    end
    f.actions
  end
   
  filter :fixed_name
  
end