ActiveAdmin.register OfferingRestrictionExemption, as: 'exemptions' do	
	batch_action :destroy, false
	config.filters = false
	menu false

	permit_params :person_id, :note, :valid_until

	breadcrumb do
	  [
  		link_to('Expo', root_path),
  		link_to('Offerings',admin_offerings_path ),
  		link_to("#{controller.instance_variable_get(:@offering).title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}" ),
  		link_to('Restrictions', admin_offering_restrictions_path),  		
  		link_to("#{controller.instance_variable_get(:@restriction).type}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}/restrictions/#{controller.instance_variable_get(:@restriction).id}" )
  	  ]
  	end

	controller do
		nested_belongs_to :offering, :restriction
		before_action :fetch_restriction

		def destroy
			@exemption = @restriction.exemptions.find(params[:id])
			@exemption.destroy

		    respond_to do |format|
		      format.html { redirect_to(admin_offering_restriction_path(@offering, @restriction)) }
		      format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut();});"}
			end
		end

		protected

		def fetch_restriction
			@offering = Offering.find params[:offering_id]
			@restriction = @offering.restrictions.find params[:restriction_id]
		end
	end

	index do
		column ('Person') {|exemption| link_to exemption.person.try(:fullname), admin_offering_restriction_exemption_path(offering, exemption.offering_restriction, exemption) }
        column :note
        column ('Valid Until'){|exemption| exemption.valid_until.to_s(:date_time12) }
		actions
    end

    show do
    	attributes_table do
    	  row :person
    	  row :note
    	  row :valid_until
    	end
    end

    sidebar 'Offering Restriction' do
  		render "admin/offerings/restrictions/restrictions", { offering: offering, offering_restriction: @restriction }
  	end

	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  f.inputs do
	  	f.input :person_id, required: true, :input_html => {style: 'width: 50%'}
	  	f.input :note, :input_html => { rows: 3, style: 'width: 50%'}
	  	f.input :valid_until, required: true, as: :date_time_picker, picker_options: {min_date: Date.current}, input_html:{style: 'width: 50%'}
  	  end
  	  f.actions
  	end

end