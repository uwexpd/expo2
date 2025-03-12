class ModeratorController < ApplicationController
  before_action :fetch_person, :fetch_offering, :apply_alternate_stylesheet, :fetch_moderator_committee_member, :fetch_offering_session, :fetch_apps  
  before_action :apply_alternate_stylesheet
  before_action :fetch_breadcrumb

  def index
    @apps = @apps.sort{|x,y| x.offering_session_order.nil? ? x.fullname <=> y.fullname : x.offering_session_order.to_i <=> y.offering_session_order.to_i }
    if request.patch? && params[:offering_session]
      @offering_session.assign_attributes(offering_session_params)
      @offering_session.title_is_temporary = false if @offering_session.title_changed?
      @offering_session.require_new_title = true if params[:finalize]
      if @offering_session.save
        flash[:notice] = "Successfully saved session deatils."
        redirect_to action: params[:finalize] ? "finalize" : "index"
      else
        flash[:error] = "Could not save session details. Please correct the errors below."
      end
    end
  end

  def show
    @app = @apps.find(params[:id])
  end

  def update
    @app = @apps.find(params[:id])
    @app.require_moderator_comments = true
    if @app.update(app_params)
      flash[:notice] = "Successfully saved decision for #{@app.fullname}."
      redirect_to :action => "index"
    else
      flash[:error] = "Could not save your decision for #{@app.fullname}. Please correct the errors below."
      render :action => "show"
    end
  end

  def finalize
    @offering_session.update(finalized: true)
    @offering_session.update(finalized_date: Time.now)
    flash[:notice] = "Your session review has been submitted. Thank you!"
    redirect_to :action => "index"
  end

  def sort_session_apps
    params[:session_apps].each_with_index do |id, index|
      presenter = @offering_session.presenters.find_by(id: id)
      presenter.update(offering_session_order: index + 1) if presenter.present?
    end
    head :ok 
  end
  
  def criteria
    render :action => 'criteria', :layout => 'popup'
  end

  protected
  
  def fetch_person
    @person = @current_user.person
  end
  
  def fetch_offering
    @offering = Offering.find params[:offering]
    #Change moderator process, don't need moderator to make decisions in 2012
    @change_moderator_process = true if @offering.year_offered > 2011
  end

  def apply_alternate_stylesheet
    if @offering && @offering.alternate_stylesheet
      @alternate_stylesheet = @offering.alternate_stylesheet
    end
  end

  def fetch_moderator_committee_member
    unless @offering.moderator_committee.nil?
      @moderator_committee_member = @offering.moderator_committee.members.find_by_person_id(@person)
      raise ExpoException.new("You are not listed as part of the moderator for that process.") and 
        return if @moderator_committee_member.nil?
    else
      raise ExpoException.new("That offering does not use moderators.") and return
    end
  end
  
  def fetch_offering_session
    @offering_session = @moderator_committee_member.offering_sessions.find_by_offering_id(@offering)
    raise ExpoException.new("You are not assigned as a moderator for any sessions.") and return if @offering_session.nil?
  end
  
  def fetch_apps
    @apps = @offering_session.presenters
  end

  def fetch_breadcrumb    
    add_breadcrumb "Moderator Interface", moderator_path
    add_breadcrumb "#{@current_user.person.fullname}"
  end    

  private

  def offering_session_params
    params.require(:offering_session).permit(:title)
  end

  def app_params
    params.require(:application_for_offering).permit(:academic_department, :approval_response, :approval_comments)
  end


end
