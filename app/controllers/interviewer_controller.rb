class InterviewerController < ApplicationController
  skip_before_action :check_if_contact_info_blank
  before_action :fetch_offering
  before_action :fetch_person, :fetch_committee_member, :except => [:ferpa_reminder, :ferpa_statement]
  before_action :fetch_offering_interviewer, :except => [:inactive, :ferpa_reminder, :ferpa_statement]
  before_action :check_if_contact_info_is_current, :except => [:update, :inactive, :ferpa_reminder, :ferpa_statement]
  before_action :check_interviewer_ferpa_reminder_date, :except => [:ferpa_reminder, :ferpa_statement]
  before_action :initialize_breadcrumbs, except: [:mark_available, :mark_unavailable]

  def index
    @interviews = @offering_interviewer.offering_interviews.sort_by(&:start_time)    
    
    render :action => 'index_scored' if @offering.uses_scored_interviews?
  end

  def show    
    @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
    @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id
    add_breadcrumb @app.fullname

    # Initialize score card if needed
    @offering_interview_interviewer.create_scores

    if params['section']
      return render :partial => "review_committee", :locals => { :audience => :reviewer } if params[:section] == 'review_committee'
      return render :partial => "admin/apply/section/#{params[:section]}", :locals => { :audience => :reviewer } 
    else
      return render :action => 'show_scored' if @offering.uses_scored_interviews?
    end
    
    if params['view'] == 'essay'
      file_path = File.join(RAILS_ROOT, 'files', @app.files.first.file.url)
      send_file file_path
    end
    if params['view'] == 'letter'
      file_path = File.join(RAILS_ROOT, 'files', @app.mentors.first.letter.url)
      send_file file_path
    end
  end
  
  def view
    # @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
    # @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id
    @app = ApplicationForOffering.find params[:id]
    if params[:file]
      file_path = File.join(RAILS_ROOT, 'files', @app.files.find(params[:file]).file.original.public_path)
    elsif params[:mentor]
      file_path = File.join(RAILS_ROOT, 'files', @app.mentors.find(params[:mentor]).letter.original.public_path)
    end
    send_file file_path unless file_path.nil?
  end
  
  def transcript
    @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
    @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id
  end
  
  def comments
    if params[:offering_interview_interviewer]
      @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
      @offering_interview_interviewer.comments = params[:offering_interview_interviewer]['comments']
      @offering_interview_interviewer.save
      flash[:notice] = "Comments saved."
    end
    respond_to do |format|
      format.js   { render :text => "Comments saved at #{Time.now.to_s(:time)}."}
      format.html { redirect_to :action => "show", :id => @offering_interview_interviewer}
    end
  end
  
  def final_decision
    @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
    @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id
    if params['application_for_offering']
      @app.set_status "interview_decision" unless @app.interview_decision_made?
      @app.attributes = params['application_for_offering']
      if @app.save
        flash[:notice] = "Decision and comments saved."
        redirect_to :action => 'index'
      else
        flash[:error] = "Could not save your decision or comments."
        render :action => "show"
      end
    end
  end

  def welcome    
    if params[:offering_interviewer]
      @offering_interviewer.special_notes = params[:offering_interviewer][:special_notes]
      @offering_interviewer.save
      flash[:notice] = "Special requests and notes saved. Thank you."
      if params[:committee] && params[:no_meeting]
        redirect_to :action => 'welcome',  :committee => params[:committee], :no_meeting => params[:no_meeting] and return 
      end        
    end
    
    yes_option_id = @offering.application_review_decision_types.find_by_yes_option(true)
    @apps = @offering.applications_with_status(:complete) + @offering.application_for_offerings.with_status(:submitted)
    
    if params[:conflict_of_interests]
      @offering_interviewer.conflict_of_interests.destroy_all
      if params[:recuse]
        params[:recuse].each do |r|
          @offering_interviewer.conflict_of_interests.create(:application_for_offering_id => r)
        end
      end
      flash[:notice] = "Conflicts of interest saved. Thank you."
      if params[:committee] && params[:no_meeting]
        redirect_to action: 'welcome', committee: params[:committee], no_meeting: params[:no_meeting] and return 
      end      
    end
    render action: 'welcome'    
  end
  
  def update
    if params[:application_reviewer] # this is for the scored review version
      @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
      @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id
      return redirect_to :action => "index" if @offering_interview_interviewer.finalized?
      if @offering_interview_interviewer.update(application_reviewer_params) && @offering_interview_interviewer.update(offering_interview_interviewer_params)
        flash[:notice] = "Interview review saved successfully."
        respond_to do |format|
          format.html { return redirect_to :action => 'index' }
          # format.js   { return render :text => "Review auto-saved at #{Time.now.to_s(:time12)}." }
        end
      else
        flash[:error] = "Could not save your responses."
      end
    elsif params["person"]
      @person = @current_user.person
      @person.attributes = params["person"]
      @person.contact_info_updated_at = Time.now
      @person.require_validations = true
      if @person.save
        flash[:notice] = "Contact information saved. Thank you."
        redirect_to redirect_to_path || url_for(:action => "index")
      else
        # render "update"
      end
    end
  end
  
  def interview_availability
    if params[:commit]
      flash[:notice] = "Thank you for submitting your availability! We will contact you as soon as interviews are scheduled."
      redirect_to committee_member_complete_path unless params[:committee].blank?
    end
  end
  
  # Marks a person available for a specific interview timeslot
  def mark_available
    t = @offering_interviewer.interview_availabilities.find_or_create_by(time: params[:time].to_time, offering_interview_timeblock_id: params[:timeblock_id])
    @b = params[:timeblock_id]
    @ti = params[:ti]
    @time = params[:time]
    respond_to do |format|
      format.html { render action: :interview_availability, notice: 'Time slot marked as available.' }
      format.js
    end
  end
  
  # Marks a person as unavailable for a specific interview timeslot
  def mark_unavailable
    t = @offering_interviewer.interview_availabilities.find_by(time: params[:time].to_time, offering_interview_timeblock_id: params[:timeblock_id])
    @b = params[:timeblock_id]
    @ti = params[:ti]
    @time = params[:time]
    if t
      t.destroy
      respond_to do |format|
        format.html { render action: :interview_availability, notice: 'Time slot marked as unavailable.' }
        format.js
      end
    else      
      respond_to do |format|
        format.html { render action: :interview_availability, alert: 'Time slot not found.' }
        format.js { render plain: 'Time slot not found.', status: :not_found }
      end
    end
  end
  
  def inactive
    # render inactive.html.erb
  end
  
  def not_this_quarter
    @offering_interviewer.destroy unless @offering_interviewer.nil?
    flash[:notice] = "You have been removed from the list of interviewers for the current quarter. Thank you!"
    redirect_to :action => "inactive"
  end

  def composite_report
    if params[:include]
      @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
      @app = ApplicationForOffering.find @offering_interview_interviewer.offering_interview.applicant_id

      parts = []
      params[:include].each do |part,value|
        parts << part.to_sym
      end
      file = @app.composite_report(@offering_interview_interviewer).pdf(parts)
      unless file.is_a?(String)
        flash[:error] = "Sorry, but there was an error creating the file. (#{file.inspect})"
        redirect_to :action => "index" and return
      end
      send_file file, :disposition => 'attachment', :type => 'application/pdf' unless file.nil?
    else
      flash[:error] = "You have to identify which parts of the application to include."
      redirect_to :action => "show", :id => params[:id]
    end
  end

  def multi_composite_report
    if params[:include] && params[:report_format]
      parts = []
      params[:include].each do |part,value|
        parts << part.to_sym
      end
      @apps = @offering_interviewer.offering_interview_interviewers.collect(&:applicant).compact
      report = MultiApplicationCompositeReport.new(@offering, @apps.sort_by(&:fullname), parts)
      report.offering_interviewer = @offering_interviewer
      file = report.generate!(params[:report_format].to_sym)
      unless file.is_a?(String)
        flash[:error] = "Sorry, but there was an error creating the file. (#{file.inspect})"
        redirect_to :action => "index" and return
      end
      send_file file, :disposition => 'attachment', :type => "application/#{params[:report_format].to_sym}" unless file.nil?
    else
      flash[:error] = "You have to identify which parts of the application to include."
      redirect_to :action => "index"
    end
  end
  
  
  def criteria
    render :action => 'criteria'
  end

  def ferpa_reminder
    # Fetch offering for this action
    @offering = Offering.find(params[:offering])
    if request.post? && params[:commit]
      @current_user.update(ferpa_reminder_date: Time.now)
      redirect_path = params[:return_to].present? ? params[:return_to] : interviewer_path(@offering)
      return redirect_to redirect_path
    end
  end

  def ferpa_statement
    # Fetch offering for this action
    @offering = Offering.find(params[:offering]) if params[:offering]
    add_breadcrumb "FERPA Reminder", interviewer_ferpa_reminder_path(@offering)
  end

  def finalize
    if params[:commit]
      for interviewer in @offering_interviewer.offering_interview_interviewers
        interviewer.update(finalized: true) if interviewer.started_scoring? && !interviewer.finalized?
      end
    end
    flash[:notice] = "Thank you! Your finalized scores were submitted."
    redirect_to :action => "index"
  end
  
  protected
  
  def fetch_person
    @person = @current_user.person
  end
  
  def fetch_offering
    @offering = Offering.find params[:offering]    
  end

  def fetch_offering_interviewer
    @offering_interviewer = @person.offering_interviewers.find_by_offering_id(@offering)    
    if @offering_interviewer.nil?
      redirect_to :action => "inactive"
    end
  end

  def fetch_committee_member
    @committee_member = CommitteeMember.where(person_id: @person.id, committee_id: params[:committee]).first if params[:committee]
  end

  # Checks to see if the contact information for this mentor is current. This is done by checking for a value in
  # person.contact_info_updated_at. If it is blank or older than 12 months, then redirect to the "update" page.
  # def check_if_contact_info_is_current
  #   update_date = @current_user.person.contact_info_updated_at
  #   if update_date.blank? || Time.now - update_date > 12.months
  #     redirect_to :action => "update", :return_to => request.request_uri
  #   end
  # end

  def initialize_breadcrumbs
    add_breadcrumb "Interviewer Interface", interviewer_path(@offering)
    add_breadcrumb @offering.title
  end

  def check_interviewer_ferpa_reminder_date
    if @current_user && session[:vicarious_user].blank?
      if @current_user.ferpa_reminder_date.nil? || @current_user.ferpa_reminder_date < 3.months.ago
        redirect_to interviewer_ferpa_reminder_path(@offering, return_to: request.fullpath) and return
      end
    end
  end

  private

  def application_reviewer_params
    params.require(:application_reviewer).permit(:application_interview_decision_type_id, :interview_feedback_person_id, :finalized, :committee_score, :comments, score_attributes: [:id, :score, :comments])
  end

  def offering_interview_interviewer_params
    params.require(:offering_interview_interviewer).permit(:application_interview_decision_type_id, :interview_feedback_person_id, :finalized, :committee_score, :comments, score_attributes: [:id, :score, :comments])
  end

end
