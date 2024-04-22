ActiveAdmin.register OfferingSession, as: 'sessions' do
  belongs_to :offering  
  batch_action :destroy, false
  config.sort_order = 'id_asc'
  menu false
  config.per_page = [50, 100, 200]

  permit_params :title, :title_is_temporary, :moderator_id, :location, :start_time, :end_time, :offering_application_type_id, :session_group, :identifier, :finalized, :uses_location_sections

  batch_action :send_to_moderators do |ids|
  	
  end

  batch_action :send_to_primary_presenters do |ids|
  	
  end


  index do
  	selectable_column
  	column ('ID') {|session| span session.identifier, class: 'tag' }
	column ('Title') {|session| link_to session.title, admin_offering_session_path(offering, session) }
	column ('Moderator') {|session| session.moderator ? link_to(session.moderator.person.fullname, admin_committee_member_path(offering.moderator_committee_id, session.moderator)) : '<span class=light>None assigned</span>'.html_safe }
	column :location
	column ('Students') {|session| session.presenters.size }
	column :finalized
	actions
  end

  show do 
  	attributes_table do
	    row ('Title'){|session| raw session.title }
        row ('Moderator'){|session| session.moderator ? session.moderator.person.fullname : '<span class=light>None Assigned</span>'.html_safe  }
        row :location
        row ('Start Time'){|session| session.start_time.to_s(:time12) }
        row ('End Time'){|session| session.end_time.to_s(:time12) }        
        row ('Application Type'){|session| session.application_type.title }
        row :session_group
        row ('finalized?'){|session| status_tag session.finalized }
	end  	
  end

  form do |f|
	  f.semantic_errors *f.object.errors.keys
	  f.inputs do
	    f.input :title
	    f.input :title_is_temporary
	    f.input :moderator_id, as: :select, collection: offering.moderators.active.sort_by(&:fullname).map{|m| [m.fullname, m.id]}, input_html: { class: 'select2'}
	    f.input :location
	    f.input :start_time
	    f.input :end_time
	    f.input :application_type, as: :select, collection: offering.application_types.map{|o|[o.title, o.id]}
	    f.input :session_group, hint: 'Use this to group sessions together; e.g., "1" and "2" or "A" and "B"'
	    f.input :identifier, hint: 'Used to sort sessions. Usually something like "1A" or "2C."'
	    f.input :finalized
	    f.input :uses_location_sections, label: 'This session uses location sections to further divide presenters'
	  end
	  f.actions
   end

  filter :title
  # filter :moderator_id
  # filter :application_type

end