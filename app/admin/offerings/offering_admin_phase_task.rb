ActiveAdmin.register OfferingAdminPhaseTask, as: 'tasks' do		
	belongs_to :offering_admin_phase	
	batch_action :destroy, false
	config.filters = false

	controller do
    	nested_belongs_to :offering, :offering_admin_phase
  	end
	

end