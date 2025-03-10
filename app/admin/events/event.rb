ActiveAdmin.register Event do  
  batch_action :destroy, false
  config.sort_order = 'id_desc'
  menu parent: 'Modules', priority: 20, label: "<i class='mi padding_right'>event</i> Events".html_safe

  permit_params :title, :description, :unit_id, :capacity, :event_type_id, :offering_id, :confirmation_email_template_id, :reminder_email_template_id, :staff_signup_email_template_id, :public, :allow_multiple_times_per_attendee, :allow_guests, :allow_multiple_positions_per_staff, :show_application_location_in_checkin, :extra_fields_to_display
  
  member_action :attendees, :method => :get do
    @event ||= Event.find(params[:id])
    @attendees = @event.attendees
    @invitees = @event.invitees
  end  

  index do
    column ('Title') {|event| link_to event.title, admin_event_path(event) }
    column ('Type') {|event| event.event_type if event.event_type}
    column ('Sponsor') {|event| event.unit.short_title if event.unit}
    column ('Times') {|event| link_to event.times.size, admin_event_times_path(event)}
    column ('Invited') {|event| event.invitees.size }
    column ('Expected') {|event| event.attendees.size }
    column ('Attended') {|event| event.attended.size }
    actions
  end
  
  show do
    attributes_table do
       row ('Public Url') {|event| link_to rsvp_event_url(event), rsvp_event_url(event) }
       unless resource.staff_positions.empty?
         row ('Staff Url') {|event| link_to volunteer_event_url(event), volunteer_event_url(event) }
       end
       row (:description) {|event| raw(event.description)}
       #row :capacity
       row :unit
       row :event_type
       row :offering
       row ('RSVP Confirmation') { |event| event.confirmation_email_template.title if event.confirmation_email_template }
       row ('RSVP Reminder') { |event| event.reminder_email_template.title if event.reminder_email_template}
       row ('Volunteer Signup Confirmation') { |event| event.staff_signup_email_template.title if event.staff_signup_email_template }
       row ('Public Event?'){|event| event.public? ? 'Public' : 'Private' }
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :title, required: true
      f.input :description, :input_html => { class: "tinymce", rows: 10 }
      #f.input :capacity, :input_html => { :style => 'width:25%;' }
      f.input :unit, label: 'Sponsor', as: :select, include_blank: false, required: true
      f.input :event_type_id, as: :select, collection: EventType.all.sort
      default_offering_id = params[:offering_id] if params[:offering_id].present?
      f.input :offering_id, as: :select, collection: Offering.order(id: :desc).map{|o| [o.title, o.id]}, selected: default_offering_id, input_html: { class: 'chosen-select' }
        div 'Optionally link this event to an offering.', class: 'caption'
      f.input :confirmation_email_template_id, label: 'Confirmation Email', as: :select, collection: EmailTemplate.order(id: :desc), :input_html => { :class => 'chosen-select' }
        div 'If you select an e-mail template here, an email will be sent to users when they RSVP that they
  			are going to attend this event.', class: 'caption'
      f.input :reminder_email_template_id, label: 'Reminder Email', as: :select, collection: EmailTemplate.order(id: :desc), :input_html => { :class => 'chosen-select' }
        div 'If you select an e-mail template here, an reminder email will be sent to attending users a day before.', class: 'caption'
      f.input :staff_signup_email_template_id, label: 'Staff Email', as: :select, collection: EmailTemplate.order(id: :desc), :input_html => { :class => 'chosen-select' }
        div 'If you select an e-mail template here, an email will be sent to staff volunteers when they select
  			a position and shift time to volunteer.', class: 'caption'
      div class: 'input' do
        label 'Options'
      end
      f.input :public, label: ' This is a public event (show it in the public events listing)', as: :boolean
      f.input :allow_multiple_times_per_attendee, label: ' Allow attendees to attend multiple event times', as: :boolean
      f.input :allow_multiple_positions_per_staff, label: " Allow volunteers to signup for multiple staff positions (as long as the shifts don't overlap)", as: :boolean
      f.input :allow_guests, label: ' Allow attendees to bring guests to this event', as: :boolean
      f.input :show_application_location_in_checkin, label: ' Show application location details (e.g., session, location section and easel number) during check-in', as: :boolean
      f.input :extra_fields_to_display, label: 'Extra Fields', as: :text, :input_html => { :rows => 4, :cols => 75}
        div 'To display extra information about an invitee when looking at the signup list, enter one item per line here.
  			Separate column title and code with a pipe, like this: "Mentor Name|invitee.application_for_offering.mentor.fullname" or 
  			"Student Number|invitee.person.student_no"', class: 'caption', :style => 'width:65%;'
    end
    f.actions
  end

  sidebar "Event Management", only: [:show, :attendees] do
    ul class: 'link-list' do
      li do        
        span link_to "<i class='mi'>how_to_reg</i> Check-in".html_safe, admin_invitees_event_path(event)
      end
      li do        
        span link_to "<i class='mi'>people_alt</i> Attendees <span class='caption' style='padding-left:0.75rem'>#{event.attendees.size} expected, #{event.attended.size} attended </span>".html_safe, attendees_admin_event_path(event)
      end
      li do        
        span link_to "<i class='mi'>badge</i> Nametags".html_safe, admin_event_path(event)
      end      
    end
  end

  sidebar "Times", only: [:show, :edit] do
    render "times", { event: event }
  end

  sidebar "Staff Positions", only: [:show] do
    render "staff_positions", { event: event }
  end

  sidebar "With Selected", only: [:attendees] do
    render "with_selected"
    # button type: 'submit', class: 'small' do
    #   i 'send', class: 'mi md-16 sub_align' 
    #   span "Send mass e-mails"
    # end
  end

  # sidebar "Event Times", only: [:show, :edit] do
  #     table do
  #       tr do
  #         td do 
  #           link_to new_admin_event_time_path(event) do            
  #             i 'add_circle', class: 'material-icons md-18'
  #           end
  #         end
  #         
  #         td link_to 'See All Times', admin_event_times_path(event)
  #       end
  #     end
  #     table_for event.times.sort do
  #       column ('Times'){|time| link_to time.time_detail, admin_event_time_path(event, time) }
  #     end
  # end
  
  filter :title, as: :string
  filter :unit_id, as: :select, collection: Unit.all.pluck(:name, :id)
  filter :event_type, as: :select, collection: EventType.all.pluck(:title, :id)

end