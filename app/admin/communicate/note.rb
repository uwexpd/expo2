ActiveAdmin.register Note do  
  config.sort_order = 'created_at_desc'
  batch_action :destroy, false  
  menu false

  permit_params :note, :contact_type_id, :notable_type, :creator_name, :access_level
end