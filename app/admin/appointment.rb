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
    @checkin_succeeded = @appointment.checkin!

    respond_to do |format|
      if @checkin_succeeded
        format.html do
          redirect_to admin_appointment_path(@appointment), notice: "Appointment with student (#{@appointment.student.fullname}) checked in."
        end
        format.js { flash.now[:notice] = "Appointment with studetn (#{@appointment.student.fullname}) checked in." }
      else
        format.html do
          redirect_to admin_appointment_path(@appointment), alert: 'Check-in failed.'
        end
        format.js { flash.now[:alert] = 'Check-in failed.' }
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

  # GET /admin/appointments/staff_people_for_unit?unit_id=123
  collection_action :staff_people_for_unit, method: :get do
    unit_id = params[:unit_id].presence

    users = User.admin
                .joins(:person)
                .where.not(people: { firstname: nil })

    if unit_id.present?
      # Uses your association: User has_many :units, through: :roles
      users = users.joins(:units).where(units: { id: unit_id })
    else
      # If you prefer “no unit => no staff”, uncomment:
      # users = users.none
    end

    payload = users
      .distinct
      .includes(:person)
      .sort_by { |u| u.person.firstname.to_s }
      .map { |u| { id: u.person_id, text: u.fullname } }

    render json: payload
  end

  # Retain the existing route name; scanning locates an appointment but does not check it in.
  collection_action :checkin_rfid, method: :post do
    resolved = resolve_rfid_student
    return if performed?
    student, student_number, student_name = resolved

    # Do not check in QuickContact records or guess among multiple appointments.
    appointments = Appointment.without_quick_contacts
                              .where(student_id: student.id, start_time: Time.zone.today.all_day)
                              .order(:start_time).to_a
    if appointments.empty?
      # Return the resolved student number so the browser can show today's empty result.
      render json: {
        status: 'no_appointment',
        student_number: student_number,
        student_name: student_name,
        message: 'No appointment scheduled for this student today.'
      }
      return
    end
    if appointments.size > 1
      render json: {
        status: 'multiple_appointments',
        student_number: student_number,
        student_name: student_name,
        message: 'Multiple appointments found today. Choose the intended appointment to check in.'
      }
      return
    end

    appointment = appointments.first
    render json: {
      status: appointment.checked_in? ? 'already_checked_in' : 'appointment_found',
      appointment_id: appointment.id,
      student_number: student_number,
      student_name: student_name,
      message: appointment.checked_in? ? 'Appointment already checked in.' : 'Appointment found. Review it and select Check in.'
    }
  rescue IdcardResource::ForbiddenError => error
    Rails.logger.error("[RFID] IDCARD access denied: #{error.class}: #{error.message}")
    render json: { error: 'The check-in application is not authorized to use IDCARD SWS.' }, status: :forbidden
  rescue StandardError => error
    Rails.logger.error("[RFID] Appointment lookup failed: #{error.class}: #{error.message}")
    render json: { error: 'Card or appointment lookup failed.' }, status: :bad_gateway
  end

  # Resolves the card for a new form; this action does not create an appointment.
  collection_action :prefill_rfid, method: :post do
    resolved = resolve_rfid_student
    return if performed?
    student, student_number, student_name = resolved

    in_person = ContactType.where('LOWER(title) = ?', 'in-person').first
    unless in_person
      render json: { error: 'The In-person contact type is not configured.' }, status: :unprocessable_entity
      return
    end

    now = Time.current
    render json: {
      student_number: student_number,
      student_id: student.id,
      student_name: student_name,
      start_time: now.beginning_of_hour.strftime('%Y-%m-%d %H:%M'),
      check_in_time: now.strftime('%Y-%m-%d %H:%M'),
      contact_type_id: in_person.id
    }
  rescue IdcardResource::ForbiddenError => error
    Rails.logger.error("[RFID] IDCARD access denied: #{error.class}: #{error.message}")
    render json: { error: 'The application is not authorized to use IDCARD SWS.' }, status: :forbidden
  rescue StandardError => error
    Rails.logger.error("[RFID] Appointment form lookup failed: #{error.class}: #{error.message}")
    render json: { error: 'Unable to look up this card.' }, status: :bad_gateway
  end


  # Controller Part  
  controller do
    def new
      @appointment = Appointment.new
      # Pre-populate student_id from params
      @appointment.student_id = params[:student_id] if params[:student_id]
      new!
    end

    private

    def resolve_rfid_student
      hex_uid = params[:rfid_uid].to_s.strip
      unless hex_uid.match?(/\A[0-9a-f]{14}\z/i)
        render json: { error: 'RFID UID must be 14 hexadecimal characters.' }, status: :unprocessable_entity
        return
      end

      card_response = IdcardResource.find_by_prox_rfid(hex_uid)
      regid = card_response.dig('Cards', 0, 'RegID')
      if regid.blank?
        render json: { error: 'No cardholder was found for this RFID card.' }, status: :not_found
        return
      end

      sws_student = StudentResource.find_by_reg_id(regid)
      student_number = sws_student&.student_no.to_s
      student = Student.find_by_student_no(student_number) if student_number.present?
      unless student
        render json: { error: 'No EXPO student record was found for this card.' }, status: :not_found
        return
      end

      [student, student_number, sws_student.fullname.to_s.strip.presence]
    end
  end

  index do
    column ('Time') {|appointment| link_to appointment.start_time.to_s(:long_time12), admin_appointment_path(appointment)}
    column ('Type') {|appointment| status_tag appointment.contact_type.title, class: 'info small' if appointment.contact_type}
    column ('Staff Person') {|appointment| appointment.staff_person.firstname_first rescue "unknown" }
    column ('Student') {|appointment| link_to appointment.student.fullname, admin_student_path(appointment.student) rescue "unknown"}
    column 'Check-in' do |appointment|
      if appointment.check_in_time.present?
        span "Checked in #{appointment.check_in_time.to_s(:time12)}", class: 'uw_green'
      else
        link_to 'Check in', checkin_admin_appointment_path(appointment),
                remote: true,
                method: :post,
                data: { confirm: "Check in this appointment with #{appointment.student.fullname}?" },
                class: "button small checkin_button_#{appointment.id}"
      end
    end
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
      f.input :unit, as: :select, prompt: "Select a Unit", required: true
      # f.input :staff_person_id, as: :select, required: true,
      #          collection: User.admin.reject{|u| u.person.firstname.nil?}.sort_by{|u| u.person.firstname}.map{|u| [u.fullname, u.person_id]}, 
      #          include_blank: false, input_html: { class: "select2 half-width-select"}
      f.input :staff_person_id,
            as: :select,
            required: true,
            collection: [],
            include_blank: false,
             input_html: {
              id: 'appointment_staff_person_id',
              class: 'select2 half-width-select',
              'data-source' => staff_people_for_unit_admin_appointments_path,
              'data-selected' => f.object.staff_person_id,
              'data-prompt' => 'Select a unit first'
            }

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
      f.input :student_id, label: 'Student EXPO ID', hint: "Please use EXPO Person ID from #{link_to 'Find Student by Name or Email.', admin_students_path, target: '_blank'}".html_safe, required: true, input_html: { style: 'width: 25%'}
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