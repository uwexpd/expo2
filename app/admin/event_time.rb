ActiveAdmin.register EventTime, as: 'times' do
  belongs_to :event
  batch_action :destroy, false
  config.filters = false
  config.sort_order = 'start_time_asc'
  
  index do  
    column ('Times') {|event_time| link_to event_time.time_detail, admin_event_time_path(event, event_time) }
    column ('Location') {|event_time| event_time.location_text.blank? ? "TBD" : event_time.location_text}
    column ('Capacity') {|event_time| event_time.capacity}
    column ('Attending') {|event_time| event_time.attendees.size }
    column 'Attended' do |event_time| 
      span event_time.attended.size
      span "(#{number_to_percentage((event_time.attended.size.to_f / event_time.attendees.size.to_f) * 100, :precision => 1)})", class: 'smaller light'
    end
    column 'Notes' do |event_time|
      event_time.full? ? (status_tag 'FULL', class: 'red small') : (status_tag 'OPEN', class: 'green small')
    end
    actions
  end
  
  show do
    attributes_table do
       row ('Event') {|event_time| link_to event.title, admin_event_path(event) }
       row ('Title') {|event_time| event_time.title }
       row ('Times') {|event_time| event_time.time_detail }      
       row ('Location') {|event_time| event_time.location_text }
       row ('Capacity') {|event_time| event_time.capacity }
       row ('Notes') {|event_time| event_time.notes }
    end
    panel 'Invitees' do
       table_for times.invitees.joins(:person).order((params[:order] ? params[:order] : 'lastname asc').gsub('_asc', ' asc').gsub('_desc', ' desc')), sortable: true do
         column('Name', sortable: 'lastname') {|invitee| invitee.person.is_a?(Student) ? (link_to invitee.person.fullname, admin_student_path(invitee.person.id)) : (link_to invitee.person.fullname, admin_person_path(invitee.person.id) rescue invitee.fullname rescue "#error") }
         column('Expected?', sortable: 'attending') {|invitee| invitee.attending? ? (status_tag 'Yes', class: 'green small') : (status_tag 'No', class: 'red small') }
         column('Attended?', sortable: 'checkin_time') {|invitee| invitee.checked_in? ? (status_tag 'Yes', class: 'ok small') : (status_tag 'No', class: 'red small') }         
       end
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :start_time, as: :datetime_picker, required: true, :input_html => { :style => 'width:50%;' }
      f.input :end_time, as: :datetime_picker, :input_html => { :style => 'width:50%;' }
      f.input :location_text, label: 'Location', :input_html => { :style => 'width:50%;' }
      f.input :title, :input_html => { :style => 'width:50%;' }
        div 'Use this title to distinguish this time slot from others.', class: 'caption'
      f.input :facilitator, :input_html => { :style => 'width:50%;' }
        div "Store a staff person's name or other information.", class: 'caption'
      f.input :capacity, :input_html => { :style => 'width:10%;' }
        div 'Leave blank for unlimited.', class: 'caption'
      f.input :notes, as: :text, :input_html => { :rows => 4, :cols => 50}
    end
    f.actions
  end
  
end