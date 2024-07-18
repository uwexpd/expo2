ActiveAdmin.register EventInvitee, as: 'invitee' do
  belongs_to :event_time, optional: true
  batch_action :destroy, false
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
  
  permit_params :event_time_id, :attending, :rsvp_comments, :number_of_guests, :checkin_time, :checkin_notes, :sub_time_id, :person_id, :mobile_checkin

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

  controller do
    before_action :fetch_event, only: [:index]
    def scoped_collection
      @event.invitees
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

  index do
    selectable_column
    column ('Invittee/Person') do |invitee|
      if invitee.person.is_a? Student 
        link_to invitee.person.fullname, [:admin, invitee.person]
      else
        link_to invitee.person.fullname, [:admin, invitee.person] rescue invitee.fullname rescue invitee.person.id rescue "#error"
      end
    end
    column ('Time'){|invitee| invitee.event_time.time_detail}
    column ('Check-in') do |invitee| 
      if invitee.checked_in?
        span "Checked in #{invitee.checkin_time.to_s(:time12) rescue relative_timestamp(invitee.checkin_time)}", class: 'uw_green'
      else
        "Not checkin yet"
      end
    end
    column :checkin_notes, sortable: :checkin_notes do |invitee|       
       editable_text_column invitee, "event_invitee", :checkin_notes, false, update_note_admin_invitee_path(invitee.id)
    end
    #column ('Note') {|invitee| invitee.checkin_notes}
    # actions
  end

  filter :event_time_id

end