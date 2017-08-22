ActiveAdmin.register Appointment do  
  actions :all, :except => [:destroy]
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'

  index do
    column ('Time') {|appointment| appointment.start_time.to_s(:long)}
    column ('Type') {|appointment| appointment.contact_type.title if appointment.contact_type.title}
    column ('Staff Person') {|appointment| appointment.staff_person.firstname_first rescue "unknown" }
    column ('Student') {|appointment| appointment.student.fullname rescue "unknown"}
    column ('Chick In Time') {|appointment| appointment.check_in_time.to_s(:long)}
    actions
  end
  
  filter :unit_id, as: :select, collection: Unit.all.pluck(:abbreviation, :id)
  filter :start_time, label: 'Date', as: :date_range
  filter :check_in_time, label: 'Checkin Date', as: :date_range
end