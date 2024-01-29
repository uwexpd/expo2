ActiveAdmin.register Quarter do
  includes :quarter_code  
  batch_action :destroy, false
  actions :all, :except => [:destroy]
  menu parent: 'Tools'

  permit_params :year, :first_day, :quarter_code  

  index do
    column ('Title'){|quarter| link_to quarter.title, admin_quarter_path(quarter.id)}
    column :year, sortable: :year
    column ('First Day'), sortable: :first_day do |quarter|
      quarter.first_day.to_s
    end    
    actions
  end

  show do
    attributes_table do
      row ('Title') {|quarter| quarter.title }
      row :year
      row :first_day
      row :quarter_code
    end    
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    inputs do
      input :year 
      input :first_day
      input :quarter_code      
    end
    actions
  end

  filter :year
  filter :first_day

end