ActiveAdmin.register EventStaffPositionShift, as: 'shift' do
  batch_action :destroy, false
  menu false
  config.filters = false

  permit_params :start_time, :end_time, :details

  controller do
    nested_belongs_to :event, :staff_position
    before_action :fetch_staff_position, except: :batch_action

    def destroy
      @shift = @staff_position.shifts.find(params[:id])
      @shift.destroy

        respond_to do |format|
          format.html { redirect_to(admin_event_staff_position_shifts_path(@event, @staff_position)) }
          format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut();});"}
      end
    end

    protected

    def fetch_staff_position    
      @event = Event.find params[:event_id]
      @staff_position = @event.staff_positions.find params[:staff_position_id]
    end

  end

  index do
    selectable_column
    column ('Times') {|shift| link_to shift.time_detail, admin_event_staff_position_shift_path(shift.position.event, shift.position, shift) }
    column ('Volunteers') {|shift| shift.staffs.size }
    actions
  end

  batch_action :send_mass_emails, confirm: "Are you sure to send mass emails?" do |ids|
    staffs = []
    EventStaff.where(id: ids).each do |staff|
      staffs << staff if staff
    end
    redirect_to admin_email_write_path("select[#{staffs.first.class.to_s}]": staffs)
  end

  show do
    attributes_table do
       row :position
       row ("Time") {|shift| shift.time_detail }
       row (:details) {|shift| raw shift.details }
    end
    panel 'Volunteers' do
      form action: batch_action_admin_shifts_path, method: :post do
        input type: :hidden, name: :authenticity_token, value: form_authenticity_token
        input type: :hidden, name: :batch_action, value: "send_mass_emails"
        table_for shift.staffs do
          column "#{check_box_tag "select_all", nil, false, id: "select-all"}".html_safe do |item|
            check_box_tag "collection_selection[]", item.id, false, class: "batch-checkbox"
          end
          column ('Name') {|staff| link_to staff.person.fullname, admin_person_path(staff.person) rescue 'Unknown'}
          column ('E-mail') {|staff| staff.person.email rescue 'Unkonwn'}          
        end
        div class: "buttons" do
          button "<i class='mi'>email</i> Send Mass E-mail With Selected".html_safe, type: :submit
        end
      end
    end
  end

    form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :start_time, as: :datetime_picker, input_html: {style: 'width: 60%'}
      f.input :end_time, as: :datetime_picker, input_html: {style: 'width: 60%'}
      f.input :details, input_html: {class: 'tinymce', rows: 4}
    end
    f.actions
  end

  sidebar "Staff Positions", only: [:show] do
    render "admin/events/staff_positions/shifts", event: shift.position.event, position: shift.position
  end

end