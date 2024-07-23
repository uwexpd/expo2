ActiveAdmin.register EventInvitee, as: 'invitee' do
  belongs_to :event_time, optional: true
  includes :person
  batch_action :destroy, false
  # config.sort_order = 'updated_at_desc'
  menu false

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
    before_action :fetch_event, only: :index
    def scoped_collection
      # for check in
      @event.attendees rescue super
    end

    def index
      @page_title = "Check in #{@event.attendees.size} attendees"
      if params[:order].blank?
        params[:order] = 'people.firstname_asc' # Default sort order if none is specified
      end
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

  member_action :update_invitee, :method => :patch do
    @invitee = EventInvitee.find(params[:id])
    if (params[:event_invitee][:attending].present? && @invitee.update(attending: params[:event_invitee][:attending]))
      render json: { success: true, message: "#{@invitee.person.firstname_first} expected attedning updated successfully" }
    elsif params[:event_invitee][:checkin_time].present? && params[:event_invitee][:checkin_time]=="true" ? @invitee.update( checkin_time: Time.now) : @invitee.update( checkin_time: nil)
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
    if @invitee && @invitee.update(checkin_time: Time.now)
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
    column ('Attendees/Person'), sortable: 'people.firstname' do |invitee|
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
        span "Group Member", class: 'light small' if invitee.invitable.is_a?(ApplicationGroupMember)
      end

      column ('Session') do |invitee|
        session = invitee.invitable.app.offering_session rescue nil
        span link_to session.title(include_identifier: true).truncate(30),
            admin_offering_session_path(session.offering, session),
            target: '_blank' rescue nil
        br
        span session.time_detail, class:'light small' rescue nil
      end    
      
      column ('Location') do |invitee| 
        span invitee.invitable.app.offering_session.location rescue nil
        #   <%= content_tag :font, 
        #   attendee.invitable.app.location_section.title, 
        #   :color => "##{attendee.invitable.app.location_section.color}" rescue nil %>

      end
      column ('Easel Number') {|invitee| invitee.invitable.app.easel_number rescue nil}    
    
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

  filter :person_firstname, as: :string
  filter :person_lastname, as: :string
  filter :event_time_id, label: 'Event times', as: :select, collection: proc {@event.times.map{|t| [t.time_detail, t.id]} }, input_html: { class: 'select2', multiple: 'multiple'}
  # filter :invitable_type, as: :select, collection: ['Person', 'ApplicationForOffering', 'ApplicationGroupMember']

end