ActiveAdmin.register Committee do
  includes :members, :meetings, :committee_quarters, :quarters
  batch_action :destroy, false
  menu parent: 'Modules', priority: 30, label: "<i class='mi padding_right'>groups</i> Committees".html_safe
  config.per_page = [30, 50, 75]
  config.sort_order = 'created_at_asc'

  permit_params :name, :intro_text, :inactive_text, :complete_text, :unit_signature, :meetings_text, :active_action_text, :show_permanently_inactive_option, :response_reset_date, :ask_for_replacement, :interview_offering_id

  index do
    column ('Name')	{|committee| link_to committee.name, admin_committee_path(committee)}
    column ('Members') {|committee| link_to committee.members.size, admin_committee_members_path(committee) }
    column ('Meetings') {|committee| link_to committee.meetings.size, admin_committee_meetings_path(committee)}
  	actions
  end

  show do
  	render 'show', { committee: committee}
  end

  sidebar 'Functions', only: [:show, :edit] do      
      # i 'person_add', class: 'material-icons md-24'
      div class: 'content-block' do
        link_to "<i class='mi md-24'>person_add</i> Add new committee member".html_safe, new_admin_committee_member_path(committee)
      end
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name, required: true
      f.input :response_reset_date, as: :datepicker, include_blank: true, :input_html => { :style => 'width:50%;' }
      div "(Optional) Used as the basis for determining if a committee member has \"responded recently.\" If blank, then the system will use the default response lifetime of #{CommitteeMember::DEFAULT_RESPONSE_LIFETIME.inspect}. If this is set, then any response after this date will be considered recent. For example, if you set this to \"October 1, 2009\" and a member hasn't responded since March of 2009, then they will be listed under the \"Not Responded\" section on the members page.", class: 'caption'
      f.input :intro_text, as: :text, :input_html => { :rows => 6, :style => 'width:100%' }
      div 'This text appears on the first page a committee member sees when he or she logs in.', class: 'caption'
      f.input :inactive_text, as: :text, :input_html => { :rows => 4, :style => 'width:100%' }
      f.input :complete_text, as: :text, :input_html => { :rows => 4, :style => 'width:100%' }
      f.input :unit_signature, as: :text, :input_html => { :rows => 4, :style => 'width:100%' }
      f.input :meetings_text, as: :text, :input_html => { :rows => 6, :style => 'width:100%' }
      f.input :active_action_text
      label 'Display options', class: 'section'
      div class: 'indent' do
	      f.input :show_permanently_inactive_option, label: 'Show "permanently inactive" option to committee members', as: :boolean
	      div 'You may not want to offer this option, especially if you only have one active quarter per year.', class: 'caption'
	      f.input :ask_for_replacement, label: 'Ask for a replacement if inactive?', as: :boolean
	      div 'This will add a text field to ask for a recommendation of another participant if the committee member chooses not to participate.', class: 'caption'
	    end
      f.input :interview_offering_id, as: :select,
               collection: Offering.all.reverse.map{|u| [u.title, u.id]},
               include_blank: true, :input_html => { :class => 'chosen-select', :style => 'width:100%;' }
      div 'Select this will automatically add committee member as an interviewer when they confirm participation. 
					 Also, this will add interview recusal and availability page into the committee member confirmation progress.', class: 'caption'
	  br
    end
    f.actions
  end

  filter :name, as: :string

end