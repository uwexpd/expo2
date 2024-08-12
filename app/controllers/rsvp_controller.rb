class RsvpController < ApplicationController
  skip_before_action :login_required, raise: false
  before_action :student_login_required_if_possible

  def index
    add_breadcrumb  "EXPO", root_path
    add_breadcrumb  "All Public EXPO Events"
    @events = Event.public_open.sort.reverse

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  def event
    add_breadcrumb  "EXPO", root_path
    add_breadcrumb  "Events", rsvp_path
    @event = Event.find(params[:id])
    apply_alternate_stylesheet(@event)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end
  
  def attend
    @event = Event.find(params[:id])
    @time = @event.times.find(params[:time_id])
    if request.post?
      if @time.full?
        flash[:error] = "Sorry, but that time slot is full. Please choose another time slot."
      elsif invitee = @time.invite!(@current_user.person, { :attending => true })
        flash[:notice] = "Thank you for your RSVP!"
        invitee.send_confirmation_email
      else
        flash[:error] = "Something went wrong. Please try again."
      end
    end
    if params[:return_to]
      redirect_to params[:return_to] and return
    else
      redirect_back(fallback_location: { action: "index" }) and return
    end
  end

  def unattend
    @event = Event.find(params[:id])
    @time = @event.times.find(params[:time_id])
    if request.delete?
      if @time.invite!(@current_user.person, { :attending => false })
        flash[:notice] = "We're sorry you'll no longer be joining us. Thank you for your reply."
      else
        flash[:error] = "Something went wrong. Please try again."
      end
    end
    if params[:return_to]
      redirect_to params[:return_to] and return
    else
      redirect_back(fallback_location: { action: "index" }) and return
    end
  end


  protected

  def apply_alternate_stylesheet(event)
    if event.offering && event.offering.alternate_stylesheet       
      @alternate_stylesheet = event.offering.alternate_stylesheet
    end
  end

end