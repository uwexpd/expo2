ActiveAdmin.register OfferingPage, as: 'pages' do	
	belongs_to :offering
	batch_action :destroy, false
	config.filters = false
	config.sort_order = 'ordering_asc'

	index do
		column ('Order') {|offering_page| offering_page.ordering }
		column ('Title') {|offering_page| link_to offering_page.title, admin_offering_pages_path(offering) }
	    column ('Questions') {|offering_page| offering_page.questions }
	    actions
	end

	show do
		
	end

	sidebar "Offering Settings", only: :index do  
        
  	end
  	sidebar "Pages", only: :show do
        
  	end




end	