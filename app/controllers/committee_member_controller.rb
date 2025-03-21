class CommitteeMemberController < ApplicationController  
  before_action :map_to_committee_member
  before_action :fetch_person
  before_action :fetch_committee_members, :except => [:map]
  before_action :assign_committee_member, :except => [:map, :which]
  before_action :initialize_breadcrumbs
  
  def which
    if params[:committee_member]
      session[:committee_member_id] = params[:committee_member][:id]
      redirect_to :action => "index"
    end
  end
  
  def index
  end
  
  def complete
  end
  
  def availability
    add_breadcrumb "Availability"
    if params[:committee_member]
      params[:committee_member][:last_user_response_at] = Time.now
      if @committee_member.update(committee_member_params)
        flash[:notice] = "Availability saved successfully."
        redirect_to :action => "complete", :inactive => "true" and return unless @committee_member.currently_active?
        chose_quarters = @committee_member.committee_member_quarters.upcoming(2).collect(&:active?).include?(true)
        redirect_to :action => "complete", :inactive => "true" and return if !chose_quarters
        # Create an interviewer record if committee.interview_offering_id
        Offering.find(@committee_member.committee.interview_offering_id).offering_interviewers.create(person_id: @committee_member.person_id) unless @committee_member.committee.interview_offering_id.blank?
        redirect_to :action => 'specialty'
      else
        flash[:error] = "Could not save your changes."
      end
    end
  end

  def specialty
    add_breadcrumb "Specialty"
    if params[:committee_member]
      if @committee_member.update(committee_member_params)
        flash[:notice] = "Specialty saved successfully."
        if @committee_member.committee_member_meetings.future.empty?      
            if @committee_member.committee.interview_offering_id.blank?
              redirect_to :action => "complete"
            else
              redirect_to offering_interviewer_path(offering: @committee_member.committee.interview_offering_id , committee: @committee_member.committee, :no_meeting => @committee_member.committee_member_meetings.future.empty?) and return
            end
        else
          redirect_to :action => "meetings"
        end                
      else
        flash[:error] = "Could not save your changes."
      end
    end
  end

  def meetings
    add_breadcrumb "#{@committee_member.committee.meetings_title_display}"
    if params[:committee_member]
      if @committee_member.update(committee_member_params)
        flash[:notice] = "All information saved."
        if @committee_member.committee.interview_offering_id.blank?
          redirect_to :action => "complete"
        else
          Offering.find(@committee_member.committee.interview_offering_id).offering_interviewers.create(:person_id => @committee_member.person_id)
          redirect_to interviewer_path(:offering => @committee_member.committee.interview_offering_id , 
                                       :action => 'welcome',
                                       :committee => @committee_member.committee, 
  					                            :no_meeting => @committee_member.committee_member_meetings.future.empty?) and return                
        end
      else
        flash[:error] = "Could not save your changes."
      end
    end
  end

  # We offer an alternative map method here because Pubcookie authentication seems to have a problem with the query parameter
  # method used in map_to_committee_member below (e.g., +?map=123&t=sdkfjsdf+).
  def map
    committee_partner_id = params[:committee_member_id]
    token = params[:token]
    if @committee_member = Token.find_object(committee_partner_id, token, false)
      @committee_member.update_attribute(:person_id, @current_user.person_id)
      @committee_member.token.generate
      profile_path(:return_to => committee_member_path)
    else
      redirect_to params[:to] || { :action => "index" }
    end
  end
  
  
  protected

  def initialize_breadcrumbs
    add_breadcrumb "Committee Member", committee_member_path
    add_breadcrumb "#{@person.fullname}"
  end

  # Maps this person to a CommitteeMember record if a valid token is sent with the URL. Note that EXPo always uses the rule that
  # "the person knows him or herself the best," so when mapping a person to a CommitteeMember, we completely disconnect from the
  # Person that was originally connected to this CommitteeMember. So if a staff person adds a new CommitteeMember to this Committee
  # (along with a new person) and says that the person's name is "Bob Smith" and then the user logs in using one of these mapped URLs
  # and the user's Person record says that his name is "Michael Jordan" we're going to trust the user and the CommitteeMember would
  # now be connected to the Michael Jordan Person record. This means that on the admin side, that Bob Smith CommitteeMember would suddenly
  # change to Michael Jordan without warning. This could potentially cause problems at some point, so this method should be revisited.
  def map_to_committee_member
    session[:committee_member_id] = params[:committee_member_id] if params[:committee_member_id]
    if params[:committee_member_id] && params[:token]
      committee_member_id = params[:committee_member_id]
      token = params[:token]
      if @committee_member = Token.find_object(committee_member_id, token, false)
          @committee_member.update_attribute(:person_id, @current_user.person_id)
          @committee_member.token.generate
          # redirect_to :action => 'profile', :to => url_for(params[:to] || {:action => 'index'})
          redirect_to profile_path(:return_to => committee_member_path)
      else
        # flash[:error] = "That login link is no longer valid. Please contact your organization service-learning supervisor."
      end
    end
  end
  
  def fetch_person
    @person = @current_user.person
  end
  
  def fetch_committee_members
    raise ExpoException.new("You aren't a member of any committees.", "If you were sent a link to login to this site, try clicking on the link again.") if @person.committees.empty?
    @committee_members = @person.committee_members
    @committees = @person.committees
  end
  
  def assign_committee_member
    redirect_to :action => "which" and return if @committees.size > 1 && !session[:committee_member_id]
    @committee_member = @committees.size == 1 ? @committee_members.first : @committee_members.find(session[:committee_member_id])
    @committee = @committee_member.committee
  end

  private

  def committee_member_params
      params.require(:committee_member).permit(:last_user_response_at, :inactive, :comment, :department, :expertise, :website_url, committee_member_quarter_attributes: [:id, :active, :comment], committee_member_meeting_attributes: [:attending, :comment])
  end
  
end
