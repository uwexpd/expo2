ActiveAdmin.register EventStaffPosition, as: 'staff_positions' do
  belongs_to :event
  batch_action :destroy, false
  config.filters = false
  config.sort_order = 'id_asc'
  
  permit_params :title, :description, :instructions, :training_session_event_id, :restrictions, :require_all_shifts

  index do
    column ('Title') {|staff_position| link_to staff_position.title, admin_event_staff_position_path(event, staff_position) }
    column ('Shifts') {|staff_position| staff_position.shifts.size }
    column :require_all_shifts
    actions
  end

  show do
    attributes_table do
       row :title
       row (:description) {|staff_position| staff_position.description.html_safe }
       row (:instructions) {|staff_position| staff_position.instructions.html_safe }       
       row :training_session_event_id
       row :restrictions
       row :require_all_shifts
    end
    # panel 'Invitees' do
    #    table_for times.invitees.joins(:person).order((params[:order] ? params[:order] : 'lastname asc').gsub('_asc', ' asc').gsub('_desc', ' desc')), sortable: true do
    #      column('Name', sortable: 'lastname') {|invitee| invitee.person.is_a?(Student) ? (link_to invitee.person.fullname, admin_student_path(invitee.person.id)) : (link_to invitee.person.fullname, admin_person_path(invitee.person.id) rescue invitee.fullname rescue "#error") }
    #      column('Expected?', sortable: 'attending') {|invitee| invitee.attending? ? (status_tag 'Yes', class: 'green small') : (status_tag 'No', class: 'red small') }
    #      column('Attended?', sortable: 'checkin_time') {|invitee| invitee.checked_in? ? (status_tag 'Yes', class: 'ok small') : (status_tag 'No', class: 'red small') }         
    #    end
    # end
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :title
      f.input :description, hint: "This brief description is shown on the page where volunteers choose which position to sign up for.", input_html: { class: "tinymce",  rows: 4}
      f.input :instructions, hint: "These instructions are shown to the volunteer after they sign up.", input_html: { class: "tinymce",  rows: 4}
      f.input :training_session_event, input_html: {class: 'select2'}
      f.input :restrictions, input_html: {rows: 4,cols: 50}
      f.input :require_all_shifts, label: 'Require volunteers to signup for all shifts at once'    
    end
    f.actions
  end


end