ActiveAdmin.register OfferingInvitationCode, as: 'invitation_codes' do
  belongs_to :offering
  batch_action :destroy, false
  menu false
  config.filters = false
  config.per_page = [30, 50, 100, 200]
  config.sort_order = 'id_desc'

  permit_params :code, :note, :institution_id

  index do
  	column ('Code'){|invitation_code| link_to invitation_code.code, admin_offering_invitation_code_path(offering, invitation_code)}
    column ('Student Application'){|invitation_code| link_to invitation_code.application_for_offering.person.fullname, admin_offering_application_path(offering, invitation_code.application_for_offering.id) if invitation_code.application_for_offering}
    column :note
    column ('Institution'){|invitation_code| invitation_code.institution_name if invitation_code.institution_id}
    actions  	
  end

  sidebar "Offering Settings", only: :index do
	render "admin/offerings/sidebar/settings", { offering: offering }
  end

  show do
  	attributes_table do
  	  row ('Offering') {|invitation_code| invitation_code.offering.name }
      row :code
      row ('Student Applicaiton') {|invitation_code| link_to invitation_code.application_for_offering.person.fullname, admin_offering_application_path(offering, invitation_code.application_for_offering), target: '_blank' if invitation_code.application_for_offering }
      row :note      
      row ('Institution') {|invitation_code| invitation_code.institution_name }
      row :created_at
      row :updated_at
  	end
  end

  form do |f|
  	semantic_errors *f.object.errors.keys
  	inputs do  	  
  	  f.input :code, input_html: { style: 'width: 50%', value: (f.object.new_record? ? OfferingInvitationCode.generate(offering, 1).code : f.object.code) }
      input :note, input_html: {style: 'width: 50%'}
      input :institution_id,  as: :select, collection: Institution.all.order(:institution_name).map{|i| [i.name, i.id]}, prompt: "Select a school (optional)", input_html: {class: 'select2'}
      actions
    end
  end

end