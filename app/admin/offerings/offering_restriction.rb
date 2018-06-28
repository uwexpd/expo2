ActiveAdmin.register OfferingRestriction, as: 'restrictions' do
	belongs_to :offering	
	batch_action :destroy, false
	config.filters = false

end