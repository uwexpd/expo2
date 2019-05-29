ActiveAdmin.register Event do  
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu parent: 'Modules', :priority => 20

  permit_params :title, :description, :unit_id, :capacity, :event_type_id, :offering_id, :confirmation_email_template_id, :reminder_email_template_id, :staff_signup_email_template_id, :public, :allow_multiple_times_per_attendee, :allow_guests, :allow_multiple_positions_per_staff, :show_application_location_in_checkin, :extra_fields_to_display
  
  index do
    column ('Title') {|event| link_to event.title, admin_event_path(event) }
    column ('Type') {|event| event.event_type if event.event_type}
    column ('Sponsor') {|event| event.unit.abbreviation if event.unit}
    column ('Times') {|event| link_to event.times.size, admin_event_times_path(event)}
    column ('Invited') {|event| event.invitees.size }
    column ('Expected') {|event| event.attendees.size }
    column ('Attended') {|event| event.attended.size }
    actions
  end
  
  show do
    attributes_table do
       row ('Public Url') {|event| link_to rsvp_event_url(event), rsvp_event_url(event) }
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
      f.input :offering_id, as: :select, collection: Offering.order('id DESC').map{|o| [o.title, o.id]}, :input_html => { :class => 'chosen-select' }
        div 'Optionally link this event to an offering.', class: 'caption'
      f.input :confirmation_email_template_id, label: 'Confirmation Email', as: :select, collection: EmailTemplate.all.sort, :input_html => { :class => 'chosen-select' }
        div 'If you select an e-mail template here, an email will be sent to users when they RSVP that they
  			are going to attend this event.', class: 'caption'
      f.input :reminder_email_template_id, label: 'Reminder Email', as: :select, collection: EmailTemplate.all.sort, :input_html => { :class => 'chosen-select' }
        div 'If you select an e-mail template here, an reminder email will be sent to attending users a day before.', class: 'caption'
      f.input :staff_signup_email_template_id, label: 'Staff Email', as: :select, collection: EmailTemplate.all.sort, :input_html => { :class => 'chosen-select' }
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

  sidebar "Times", only: [:show, :edit] do  
        render "times", { event: event }
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