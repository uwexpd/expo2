ActiveAdmin.register EventStaffPosition, as: 'staff_position' do
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
    panel 'Shifts' do
       table_for staff_position.shifts do
         column ('Times') {|shift| link_to shift.time_detail, admin_event_staff_position_shift_path(staff_position.event, staff_position, shift) }
         column ('Volunteers') {|shift| shift.staffs.size }
         column ('Functions'){|shift|
            span link_to '<span class="mi">visibility</span>'.html_safe, admin_event_staff_position_shift_path(event, staff_position, shift), class: 'action_icon'
            span link_to '<span class="mi">edit</span>'.html_safe, edit_admin_event_staff_position_shift_path(event, staff_position, shift), class: 'action_icon'
            span link_to '<span class="mi">delete</span>'.html_safe, admin_event_staff_position_shift_path(event, staff_position, shift), method: :delete, data: { confirm:'Are you sure?', :remote => true}, class: 'delete action_icon'
               }
       end
       div class: 'padding' do
        link_to '<span class="mi md-20">add_circle</span>New Shift'.html_safe, new_admin_event_staff_position_shift_path(event, staff_position), class: 'button'
       end
    end    
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :title
      f.input :description, hint: "This brief description is shown on the page where volunteers choose which position to sign up for.", input_html: { class: "tinymce",  rows: 4}
      f.input :instructions, hint: "These instructions are shown to the volunteer after they sign up.", input_html: { class: "tinymce",  rows: 4}
      f.input :training_session_event, input_html: {class: 'select2'}
      f.input :restrictions, input_html: {rows: 4}
      f.input :require_all_shifts, label: 'Require volunteers to signup for all shifts at once'    
    end
    f.actions
  end

  sidebar "Staff Positions", only: [:show] do
    render "admin/events/staff_positions", event: staff_position.event
  end


end