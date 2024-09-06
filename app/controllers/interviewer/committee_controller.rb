class Interviewer::CommitteeController < InterviewerController
  before_action :add_committee_breadcrumbs
  before_action :fetch_offering_interview_interviewer, :except => [:index, :update, :finalize, :criteria]
  before_action :fetch_offering_interview_interviewer_from_id, :only => [ :update ]
  
  def index
    @apps = @offering_interviewer.offering_interview_interviewers.collect(&:applicant).compact
    @apps = @apps.sort_by(&:fullname)
    render :action => 'index_scored' if @offering.uses_scored_interviews?
  end
  
  # Updates the scoring pane to accept scores for the specified app
  def show
    respond_to do |format|
      format.js
    end
  end
  
  def criteria
    redirect_to interviewer_criteria_path
  end

  def finalize
    if params[:commit]
      @apps = @offering_interviewer.offering_interview_interviewers.collect(&:applicant).compact
      for interviewer in @apps.collect{|a| a.interview.interviewers.find_or_create_by(committee_score: true)}
        interviewer.update(finalized: true) if interviewer.started_scoring? && !interviewer.finalized?
      end
    end
    flash[:notice] = "Thank you! Your finalized scores were submitted."
    redirect_to :action => "index"
  end

  
  protected
  
  def add_committee_breadcrumbs    
    add_breadcrumb "Committee Decisions", interview_committee_path    
  end
  
  def fetch_offering_interview_interviewer
    @app = ApplicationForOffering.find params[:id]
    @offering_interview_interviewer = @app.interview.interviewers.find_or_create_by(committee_score: true)
    @offering_interview_interviewer.create_scores
  end

  def fetch_offering_interview_interviewer_from_id
    @offering_interview_interviewer = OfferingInterviewInterviewer.find params[:id]
  end
    
end