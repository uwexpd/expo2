ActiveAdmin.register Appointment do
  actions :all
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu parent: 'Modules', :priority => 15, label: "<i class='mi padding_right'>schedule</i> Appointments".html_safe
  scope :all, default: true
  scope 'Today', :today
  scope 'Tomorrow', :tomorrow
  scope 'Yesterday', :yesterday
  active_admin_import template: 'admin/appointments/import'

  permit_params :start_time, :end_time, :unit_id, :staff_person_id, :student_id, :check_in_time, :notes, :front_desk_notes, :type, :drop_in, :contact_type_id, :follow_up_notes

   member_action :checkin, method: :post do
    @appointment = Appointment.find(params[:id])

    if @appointment.checkin!
      respond_to do |format|
        format.html { redirect_to admin_appointment_path(@appointment) }        
      end
    else
      respond_to do |format|
        format.html { redirect_to admin_appointment_path(@appointment), alert: "Check-in failed." }        
      end
    end
  end

  member_action :followup_to, method: [:post, :patch] do
    @appointment = Appointment.find(params[:id])
    @appointment.update(previous_appointment_id: params[:previous_appointment_id])

    respond_to do |format|
      format.html { redirect_to admin_appointment_path(@appointment) }
      format.js
    end
  end
  
  controller do
    def new
      @appointment = Appointment.new
      # Pre-populate student_id from params
      @appointment.student_id = params[:student_id] if params[:student_id]
      new!
    end
  end

  index do
    column ('Time') {|appointment| link_to appointment.start_time.to_s(:long_time12), admin_appointment_path(appointment)}
    column ('Type') {|appointment| status_tag appointment.contact_type.title, class: 'info small' if appointment.contact_type}
    column ('Staff Person') {|appointment| appointment.staff_person.firstname_first rescue "unknown" }
    column ('Student') {|appointment| link_to appointment.student.fullname, admin_student_path(appointment.student) rescue "unknown"}
    column ('Chick In Time') {|appointment| appointment.check_in_time.to_s(:time12) if appointment.check_in_time }
    actions
  end
  
  show do
    render "admin/students/student_header", { student: appointment.student }
    attributes_table do
      row (:start_time) {|appointment| appointment.start_time.to_s(:date_pretty)}            
      row :unit
      row :staff_person
      row :drop_in
      row(:check_in_time) do |appointment|
        next unless appointment.check_in_time
        content_tag(:span, appointment.check_in_time.to_s(:date_pretty), class: "uw_green")
end
      row :contact_type
      row :front_desk_notes
      row :notes
      row :follow_up_notes
      row (:source) {|appointment| appointment.source.titleize if appointment.source}
    end
  end

  sidebar "Actions", only: :show, if: proc { resource.check_in_time.blank? } do 
      div class: 'padding_left' do
        link_to "<i class='mi'>how_to_reg</i> Check in".html_safe,
              checkin_admin_appointment_path(resource),
              method: :post,
              data: { confirm: "Check in this appointment?" },
              class: 'button flat'
      end
  end

  sidebar "Other Appointments", only: :show do
    other_appointments = Appointment.where(student_id: resource.student_id).where.not(id: resource.id).order(start_time: :desc) 
      
    ul class: "link-list" do
      if other_appointments.blank?
        li class: "empty" do
          "No other appointments"
        end
      else
        other_appointments.each do |other_appointment|
          li do
            render partial: "admin/appointments/other_appointment",
                   locals: { other_appointment: other_appointment, appointment: resource }
          end
        end
      end
    end
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :start_time, as: :date_time_picker, required: true, :input_html => { :style => 'width:50%;' }
      f.input :end_time, as: :date_time_picker, :input_html => { :style => 'width:50%;' }
      f.input :unit, as: :select, include_blank: false, required: true
      f.input :staff_person_id, as: :select, required: true,
               collection: User.admin.reject{|u| u.person.firstname.nil?}.sort_by{|u| u.person.firstname}.map{|u| [u.fullname, u.person_id]}, 
               include_blank: false, input_html: { class: "select2", style: "width: 50%"}

      # Student Number Search Field outside of f.inputs
      li class: 'number input optional numeric stringish' do
        raw %{
          <div class="student-lookup" data-target="#appointment_student_id">
            <label class="label">Student ID Search by Student Number</label>
            <div style="display:flex; align-items:center; gap:10px;">
              <input type="text" class="student-number-search" placeholder="Enter 7-digit student number" style="width:25%;">
              <a href="#" class="button student-search-btn">Search</a>
              <span class="student-search-result" style="margin-left:5px;"></span>
            </div>
          </div>
        }
      end
      f.input :student_id, label: 'Student EXPO ID', hint: "Please use EXPO Person ID from #{link_to 'Find Student by Name or Email.', admin_students_path, target: '_blank'}".html_safe, input_html: { style: 'width: 25%'}
      f.input :check_in_time, as: :date_time_picker, :input_html => { style: 'width:50%;' }
      f.input :drop_in
      f.input :contact_type_id, as: :select, collection: ContactType.all
      f.input :front_desk_notes, :input_html => { :rows => 3, :style => 'width:50%;' }
      f.input :notes, :input_html => { :rows => 3, :style => 'width:50%;' }
      f.input :follow_up_notes, :input_html => { :rows => 3, :style => 'width:50%;' }
    end
    f.actions
  end
  filter :student_no_search_eq, label: 'Student Number'
  filter :staff_person, as: :select, collection: User.admin.reject{|u| u.person.firstname.nil?}.sort_by{|u| u.person.firstname}.map{|u| [u.fullname, u.person_id]}, input_html: { class: 'select2', multiple: 'multiple'}
  filter :unit_id, as: :select, collection: Unit.all.pluck(:name, :id), input_html: { class: 'select2', multiple: 'multiple'}
  filter :start_time, label: 'Date', as: :date_range
  filter :check_in_time, label: 'Checkin Date', as: :date_range
end