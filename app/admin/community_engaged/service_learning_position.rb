ActiveAdmin.register ServiceLearningPosition do  
  batch_action :destroy, false
  config.sort_order = 'title'
  config.per_page = [30, 50, 100, 200, 300]
  menu parent: 'Tools'
  
  scope "#{Quarter.current_quarter.title}", :current_quarter, default: true
  scope "All", :sorting

  permit_params :title, :organization_quarter_id
  
  index do     
     column ('Title') {|position| link_to raw(position.title), admin_service_learning_position_path(position) }
     column ('Organization') {|position| position.organization.title }
     
     column ('Filled') {|position| position.filled_placements_count}
     column ('Total') {|position| position.total_placements_count}
     column ('Unallocated') {|position| position.unallocated_placements_count}
     column :unit
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
      f.input :title
      f.input :description, :input_html => { :rows => 3 }
    end
    f.actions
  end
   
  filter :title  
  filter :organization_quarter_quarter_id, label: 'Quarter', as: :select, collection: (Quarter.current_and_future_quarters(3) + Quarter.past_quarters(60)).sort.reverse!.map{|a|[a.title, a.id]}, input_html: { class: "select2", multiple: 'multiple'}
  filter :organization_quarter_organization_name, as: :string, label: 'Organization'
  filter :unit, input_html: { class: 'select2', multiple: 'multiple'}
  
  
end