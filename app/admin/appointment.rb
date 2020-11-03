ActiveAdmin.register Appointment do  
  actions :all
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu parent: 'Modules', :priority => 15
  scope :all, default: true
  scope 'Today', :today
  scope 'Tomorrow', :tomorrow
  scope 'Yesterday', :yesterday
  active_admin_import template: 'admin/appointments/import'

  permit_params :start_time, :end_time, :unit_id, :staff_person_id, :student_id, :check_in_time, :notes, :front_desk_notes, :type
  
  index do
    column ('Time') {|appointment| link_to appointment.start_time.to_s(:long_time12), admin_appointment_path(appointment)}
    column ('Type') {|appointment| status_tag appointment.contact_type.title, class: 'small' if appointment.contact_type}
    column ('Staff Person') {|appointment| appointment.staff_person.firstname_first rescue "unknown" }
    column ('Student') {|appointment| appointment.student.fullname rescue "unknown"}
    column ('Chick In Time') {|appointment| appointment.check_in_time.to_s(:time12) if appointment.check_in_time }
    actions
  end
  
  show do
    #panel '' do
      render "admin/students/student_header", { student: appointment.student }
      # div :class => 'content-block' do
      #   #image_tag photo_admin_student_path(appointment.student.reg_id)
      #   h1 "#{appointment.student.fullname}" do
      #     span "#{appointment.student.student_no}", :class => 'light small'          
      #   end
      #   div do
      #     "#{appointment.student.sdb.class_standing_description(:show_upcoming_graduation => true)}, #{appointment.student.sdb.majors_list(true, ', ')}"
      #   end
      #   div do
      #     "#{appointment.student.email}"
      #   end
      # end
    #end
    attributes_table do
      row (:start_time) {|appointment| appointment.start_time.to_s(:date_pretty)}            
      row :unit
      row :staff_person
      row :drop_in
      row (:check_in_time) {|appointment| appointment.check_in_time.to_s(:date_pretty) if appointment.check_in_time}
      row :front_desk_notes
      row :notes
      row :source
    end
  end

  sidebar "Other Appointments", only: :show do
      
  end
  
  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :start_time, as: :date_time_picker, required: true, :input_html => { :style => 'width:50%;' }
      f.input :end_time, as: :date_time_picker, :input_html => { :style => 'width:50%;' }
      f.input :unit, as: :select, include_blank: false, required: true
      f.input :staff_person_id, as: :select, required: true,
               collection: User.admin.reject{|u| u.person.firstname.nil?}.sort_by{|u| u.person.firstname}.map{|u| [u.fullname, u.person_id]}, 
               include_blank: false, :input_html => { :class => 'chosen-select', :style => 'width:34%;' }
      f.input :student_id, label: 'Student EXPO ID', :input_html => { :style => 'width:50%;' }
      f.input :check_in_time, as: :date_time_picker, :input_html => { :style => 'width:50%;' }
      f.input :drop_in
      f.input :contact_type_id, as: :select, collection: ContactType.all
      f.input :front_desk_notes, :input_html => { :rows => 3, :style => 'width:50%;' }
      f.input :notes, :input_html => { :rows => 3, :style => 'width:50%;' }
      f.input :follow_up_notes, :input_html => { :rows => 3, :style => 'width:50%;' }
    end
    f.actions
  end
  
  filter :unit_id, as: :select, collection: Unit.all.pluck(:abbreviation, :id)
  filter :start_time, label: 'Date', as: :date_range
  filter :check_in_time, label: 'Checkin Date', as: :date_range
end