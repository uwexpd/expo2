ActiveAdmin.register EventInvitee, as: 'invitee' do
  belongs_to :event_time, optional: true
  includes :person
  batch_action :destroy, false
  config.sort_order = 'people.firstname_asc'
  menu false
  actions :all, except: [:new]

  scope :all, default: true
  scope 'Checked in', :checked_in
  scope 'Not Checked in', :not_checked_in

  breadcrumb do
    breadcrumbs = [
      link_to('Expo', "/expo"), 
      link_to('Events', admin_events_path),      
    ]
    if controller.instance_variable_get(:@event)
      event_link = link_to(controller.instance_variable_get(:@event).title, admin_event_path(controller.instance_variable_get(:@event).id))
      breadcrumbs << event_link
    end    
    breadcrumbs
  end
  
  permit_params :invitable_id, :invitable_type, :event_time_id, :attending, :rsvp_comments, :number_of_guests, :checkin_time, :checkin_notes, :sub_time_id, :person_id, :mobile_checkin

  controller do
    before_action :fetch_event, only: [:index, :mass, :mass_checkin]
    def scoped_collection
      # Check in invitees
      if params[:q].present? && params[:q][:student_number_eq].present?        
        @event.invitees.student_number_eq(params[:q][:student_number_eq])
      else
        @event.invitees rescue super
      end
    end

    def index
      @page_title = "Check in #{@event.invitees.size} invitees"
      super
    end
      
    def destroy
      @invitee = EventInvitee.find(params[:id])
      @invitee.destroy
        respond_to do |format|
          format.html {redirect_to(admin_time_invitee_path(event_time, invitee))}
          format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut(400);});"}
      end
    end

    private

    def fetch_event
      @event = Event.find(params[:event_id])      
    end
  end

  action_item :rfid_event_context, only: :index do
    current_event = controller.instance_variable_get(:@event)
    span '', id: 'rfid-event-context', 'data-rfid-event-id' => current_event.id,
         style: 'display:none' if current_event
  end

  action_item :mass_checkin, only: :index do
    link_to "Mass check-in (paste list)",
            url_for(action: :mass, event_id: params[:event_id])
  end

  collection_action :mass, method: :get do    
    @event_time = @event.times.find_by(id: params[:event_time_id]) || @event.times.first
    @not_found = []
  end

  collection_action :mass_checkin, method: :post do    
    @event_time = @event.times.find(params[:event_time_id]) rescue @event.times.first

    raw = params[:students].to_s
    if raw.blank?
      flash.now[:alert] = "You must provide a list of student numbers or NetID's."
      @not_found = []
      render :mass and return
    end

    tokens = raw.split(/\r?\n|,|\t|\s+/).map(&:strip).reject(&:blank?).uniq
    now = Time.current

    success = 0
    already = 0
    not_found = []

    tokens.each do |t|
      student =
        if t.match?(/\A\d+\z/)
          Student.find_by_student_no(t)
        else
          Student.find_by_uw_netid(t)
        end

      unless student
        not_found << t
        next
      end

      invitee = @event_time.invite!(student, checkin_time: now)

      if invitee.nil?
        # should not happen unless student nil, but safe
        next
      end

      if invitee.previous_changes.key?("checkin_time")
        success += 1
      elsif invitee.checkin_time.present?
        already += 1
      end
    end

    flash[:notice] = "Checked in: #{success}. Already checked in: #{already}." if (success + already) > 0

    if not_found.any?
      flash.now[:alert] = "Not found: #{not_found.size}. See this page below."
      @not_found = not_found
      render :mass and return
    end

    redirect_to admin_event_time_path(@event, @event_time.id )
  end
  
  collection_action :lookup_rfid, method: :post do
    hex_uid = params[:rfid_uid].to_s.strip
    unless hex_uid.match?(/\A[0-9a-f]{14}\z/i)
      render json: { error: 'RFID UID must be 14 hexadecimal characters.' }, status: :unprocessable_entity
      return
    end

    # On the nested route :time_id is the EventTime ID, not the Event ID.
    nested_time = EventTime.find_by(id: params[:time_id]) if params[:time_id].present?
    event = nested_time&.event || Event.find_by(id: params[:event_id])
    unless event && (params[:time_id].blank? || nested_time) &&
           (params[:event_id].blank? || event.id.to_s == params[:event_id].to_s)
      render json: { error: 'Open check-in for a specific event before scanning.' }, status: :unprocessable_entity
      return
    end

    selected_time_id = params[:event_time_id].presence || nested_time&.id
    selected_time = event.times.find_by(id: selected_time_id) if selected_time_id.present?
    if selected_time_id.present? && !selected_time
      render json: { error: 'The selected event time does not belong to this event.' }, status: :unprocessable_entity
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

    # Preserve an existing event invitation, even when its time differs from the
    # selected time. Never silently pick among multiple invitations.
    invitees = event.invitees.where(person_id: student.id).to_a
    invitee = invitees.find { |item| item.event_time_id == selected_time.id } if selected_time
    invitee ||= invitees.first if invitees.one?
    if !invitee && invitees.any?
      render json: { error: 'This student has multiple invitations. Select the correct event time.' }, status: :conflict
      return
    end

    if !invitee && !selected_time
      times = event.times.to_a
      selected_time = times.first if times.one?
    end
    unless invitee || selected_time
      render json: { error: 'Select a check-in event time before scanning an uninvited student.' }, status: :unprocessable_entity
      return
    end

    already_checked_in = invitee&.checked_in?
    unless already_checked_in
      EventInvitee.transaction do
        invitee ||= selected_time.invite!(student)
        raise ActiveRecord::RecordInvalid.new(invitee) unless invitee&.persisted?
        raise ActiveRecord::RecordInvalid.new(invitee) unless invitee.checkin!
      end
    end

    render json: {
      status: already_checked_in ? 'already_checked_in' : 'checked_in',
      student_number: student_number,
      event_time_id: invitee.event_time_id,
      message: already_checked_in ? 'Student already checked in.' : 'Student successfully checked in.'
    }
  rescue IdcardResource::ForbiddenError => error
    Rails.logger.error("[RFID] IDCARD access denied: #{error.class}: #{error.message}")
    render json: { error: 'The check-in application is not authorized to use IDCARD SWS.' }, status: :forbidden
  rescue ActiveRecord::RecordInvalid => error
    Rails.logger.error("[RFID] Event check-in failed: #{error.class}: #{error.message}")
    render json: { error: 'Could not check in this student.' }, status: :unprocessable_entity
  rescue StandardError => error
    Rails.logger.error("[RFID] Event check-in failed: #{error.class}: #{error.message}")
    render json: { error: 'Card lookup or event check-in failed.' }, status: :bad_gateway
  end

  member_action :update_invitee, :method => :patch do
    @invitee = EventInvitee.find(params[:id])
    if (params[:event_invitee][:attending].present? && @invitee.update(attending: params[:event_invitee][:attending]))
      render json: { success: true, message: "#{@invitee.person.firstname_first} expected attedning updated successfully" }
    elsif params[:event_invitee][:checkin_time].present? && params[:event_invitee][:checkin_time]=="true" ? @invitee.update( checkin_time: Time.current) : @invitee.update( checkin_time: nil)
      render json: { success: true, message: "#{@invitee.person.firstname_first} attended status updated successfully" }
    else
      render json: { success: false, message: "Error updating this invitee" }, status: :unprocessable_entity
    end    
  end

  member_action :update_note, :method => :put do    
    @invitee = EventInvitee.find(params[:id])
    if @invitee.update(checkin_notes: params[:event_invitee][:checkin_notes])
       render json: { success: true, message: "Checkin notes updated successfully" }
    else
       render json: { success: false, message: "Error updating this invitee" }, status: :unprocessable_entity
    end
  end

  member_action :checkin, method: :patch do 
    @invitee = EventInvitee.find(params[:id])
    if @invitee && @invitee.update(checkin_time: Time.current)
      flash[:notice] = "#{@invitee.invitable.firstname_first} was successfully checked in."
      respond_to do |format|
        format.html { render :index }
        format.js
      end
    else
      @error_message = "Could not complete your request. (Invitee ID: #{params[:id].to_s})" 
      flash[:alert] = @error_message
    end
  end

  batch_action :mass_checkin, confirm: "Are you sure to mass checkin with selected invitees?" do |ids|
    checkedin_invitees = []
    batch_action_collection.find(ids).each do |invitee|      
      if invitee && invitee.update(checkin_time: Time.now)
        checkedin_invitees << invitee
      end
    end    
    redirect_to request.referer, notice: "Successfully checked in #{checkedin_invitees.size} " + "invitee".pluralize(checkedin_invitees.size)
  end


  index do
    selectable_column
    column ('Invitees / Person'), sortable: 'people.firstname' do |invitee|
      if invitee.person.is_a? Student 
        link_to invitee.person.firstname_first, [:admin, invitee.person], target: '_blank'
      else
        link_to invitee.person.fullname, [:admin, invitee.person] rescue invitee.fullname rescue invitee.person.id rescue "#error"
      end
    end
  
    if event.show_application_location_in_checkin?
      column ('Project') do |invitee| 
        span link_to "View project", admin_offering_application_path(invitee.application_for_offering.offering, invitee.application_for_offering), target: '_blank' rescue nil
        br
        span "Group Member", class: 'light smaller' if invitee.invitable.is_a?(ApplicationGroupMember)
      end

      column ('Session') do |invitee|
        session = invitee.invitable.app.offering_session rescue nil
        span link_to session.title(include_identifier: true).truncate(30),
            admin_offering_session_path(session.offering, session),
            target: '_blank' rescue nil
        br
        span session.time_detail, class:'light smaller' rescue nil
      end    
      
      column ('Location') do |invitee| 
        span invitee.invitable.app.offering_session.location rescue nil
        #   <%= content_tag :font, 
        #   attendee.invitable.app.location_section.title, 
        #   :color => "##{attendee.invitable.app.location_section.color}" rescue nil %>

      end
      column ('Easel Number') {|invitee| invitee.invitable.app.easel_number rescue nil}    
      
      column 'Group Members' do |invitee|
        if invitee.invitable.respond_to?(:app)
          if invitee.invitable.is_a?(ApplicationGroupMember)
            if primary_invitee = invitee.invitable.app.event_invitees.for_event(event).first
              if primary_invitee.checked_in?
                span "Primary presenter (#{primary_invitee.invitable.firstname_first}): #{relative_timestamp(primary_invitee.checkin_time)}", class: 'uw_green smaller'
              else
                span "Primary presenter (#{primary_invitee.invitable.firstname_first}): Not checked in.", class: 'red_color smaller'
              end
            end
          else
            # Display group members check in status for primary presenter
            invitee.invitable.app.group_members.each do |group_member|
              group_invitee = group_member.event_invitees.for_event(event).first
              if group_invitee.blank?
                para "#{group_member.firstname_first}: No check-in status available.", class: 'red_color smaller'
              elsif group_invitee.checked_in?
                para "#{group_invitee.firstname_first}: #{relative_timestamp(group_invitee.checkin_time)}", class: 'uw_green smaller'
              else
                para "#{group_member.firstname_first}: Not checked in.", class: 'red_color smaller'
              end
            end
          end        
        end
        span "" 
      end

    end

    column ('Time'){|invitee| invitee.event_time.time_detail} if event.times.size > 1
    column ('Check-in'), sortable: :checkin_time do |invitee| 
      if invitee.checked_in?
        span "Checked in #{relative_timestamp(invitee.checkin_time) rescue invitee.checkin_time.to_s(:time12)}", class: 'uw_green'
      else
       # "Not checkin yet"
       link_to 'Check in', checkin_admin_invitee_path(invitee.id), remote: true, method: :patch, class: "button small checkin_button_#{invitee.id}"
      end
    end
    column :checkin_notes, sortable: :checkin_notes do |invitee|       
       editable_text_column invitee, "event_invitee", :checkin_notes, false, update_note_admin_invitee_path(invitee.id)
    end
    #column ('Note') {|invitee| invitee.checkin_notes}
    # actions
  end

  # A separate check-in choice; the existing "Event times" filter only filters rows.
  sidebar 'Check-in time', only: :index do
    current_event = controller.instance_variable_get(:@event)
    if current_event
      times = current_event.times.order(:start_time).to_a
      nested_time_id = params[:time_id].presence
      selected_id = nested_time_id || params[:event_time_id].presence || (times.first.id if times.one?)

      if nested_time_id
        selected_time = times.find { |time| time.id.to_s == nested_time_id.to_s }
        div class: 'content-block' do
          label 'Check in for :'
          span selected_time ? selected_time.time_detail : 'Invalid event time'
        end
      else
        div class: 'content-block' do
          label 'Check in for :', for: 'rfid_event_time_id'
          text_node select_tag(
            :rfid_event_time_id,
            options_from_collection_for_select(times, :id, :time_detail, selected_id.to_s),
            include_blank: (times.size > 1 ? 'Select an event time' : false),
            id: 'rfid_event_time_id',
            class: 'select2'
          )
        end
      end
    end
  end

  filter :person_firstname, as: :string
  filter :person_lastname, as: :string
  # filter :person_student_no_eq => Not working cuz person student no might be blank
  filter :student_number_eq, label: 'Student number'
  filter :event_time_id, label: 'Event times', as: :select, collection: proc {@event.times.map{|t| [t.time_detail, t.id]} }, input_html: { class: 'select2', multiple: 'multiple'}
  # filter :invitable_type, as: :select, collection: ['Person', 'ApplicationForOffering', 'ApplicationGroupMember']

end