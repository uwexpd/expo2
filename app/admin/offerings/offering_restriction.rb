ActiveAdmin.register OfferingRestriction, as: 'restrictions' do
	belongs_to :offering	
	batch_action :destroy, false
	config.filters = false
	config.sort_order = 'ordering_type'

	permit_params :type, :note, :extra_detail, :parameter

	index do
	  column ('Type') do |restriction| 
	  	div link_to(restriction.type, admin_offering_restriction_path(offering, restriction))
	  	small restriction.title, class: 'light'
	  end
	  column ('Exemptions'){|restriction| link_to restriction.exemptions.count, admin_offering_restriction_exemptions_path(offering, restriction) }
	  column :extra_detail
	  actions
	end

	sidebar "Offering Settings", only: :index do
		render "admin/offerings/sidebar/settings", { offering: offering }
  	end

  	sidebar 'Offering Restriction', only: [:show, :edit] do
  		render "admin/offerings/restrictions/restrictions", { offering: offering, offering_restriction: restrictions }
  	end

  	show do
  	  attributes_table do
	    row :type
        row ('Preview') do |restriction|
        	b restriction.title
			para restriction.detail
			para restriction.extra_detail
        end
	  end
  	  panel '' do
  	  	h2 'Current Exemptions'
		div :class => 'content-block' do
			table_for restrictions.exemptions, id: 'show_table_offering_exemptions' do              
              column ('Person') {|exemption| exemption.person.try(:fullname) }
              column :note
              column ('Valid Until'){|exemption| exemption.valid_until.to_s(:date_time12) if exemption.valid_until }
			  column ('Functions'){|exemption|						
						span link_to '<span class="material-icons">edit</span>'.html_safe, edit_admin_offering_restriction_exemption_path(offering, restrictions, exemption), class: 'action_icon'
						span link_to '<span class="material-icons">delete</span>'.html_safe, admin_offering_restriction_exemption_path(offering, restrictions, exemption), method: :delete, data: { confirm:'Are you sure?', :remote => true}, class: 'delete action_icon'
			         }
			end
			div link_to '<span class="material-icons md-20">add</span>Add New Exemption'.html_safe, new_admin_offering_restriction_exemption_path(offering, restrictions), class: 'button add'
		end
	  end
  	end
  	
  	form do |f|
	  f.semantic_errors *f.object.errors.keys
	  f.inputs do
	  	f.input :type, as: :select, collection: %w(OfferingRestriction BeforeOpenRestriction FulltimeStudentRestriction MustBeStudentRestriction PastDeadlineRestriction StateResidentRestriction GpaRestriction MajorRestriction).sort
	  	f.input :extra_detail, :input_html => { rows: 3, style: 'width: 60%' }, hint: 'This text is appended to the error message that users receive if they fail the restriction.'
	  	f.input :parameter, :input_html => { rows: 2, style: 'width: 60%' }, hint: 'If this restriction requires an extra parameter to check (e.g., a minimum GPA for the GpaRestriction or a list of major abbreviations for the MajorRestriction), enter that parameter
			here.'
  	  end
  	  f.actions
  	end

end