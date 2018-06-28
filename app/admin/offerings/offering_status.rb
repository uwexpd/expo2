ActiveAdmin.register OfferingStatus, as: 'statuses' do
	belongs_to :offering
	batch_action :destroy, false
	config.filters = false
	
	
	

end