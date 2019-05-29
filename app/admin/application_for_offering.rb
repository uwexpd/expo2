ActiveAdmin.register ApplicationForOffering do  
  actions :all, :except => [:destroy]
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu false
  
  #belongs_to :offering  

  index do
  
  end


end 