ActiveAdmin.register OfferingQuestion do
	belongs_to :offering_page
	batch_action :destroy, false
	config.filters = false




end	