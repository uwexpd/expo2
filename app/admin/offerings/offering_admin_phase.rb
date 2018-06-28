ActiveAdmin.register OfferingAdminPhase, as: 'phases' do
	belongs_to :offering
	batch_action :destroy, false
	config.filters = false
	
	
	

end