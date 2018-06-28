ActiveAdmin.register OfferingDashboardItem, as: 'dashboard_items' do
	belongs_to :offering
	batch_action :destroy, false
	config.filters = false
	
	
	

end