class Reviewer::CommitteeController < ReviewerController
  before_action :add_committee_breadcrumbs
  before_action :fetch_application_reviewer, :except => [:index, :criteria, :finalize]
  
  def index
    @apps = @apps.sort_by(&:fullname)    
    render :action => 'index_scored' if @offering.uses_scored_review?
  end

  # Updates the scoring pane to accept scores for the specified app
  def show
    respond_to do |format|
      format.js
    end
  end
  
  def criteria
    redirect_to reviewer_criteria_path
  end

  def finalize
    if params[:commit]
      @apps.collect{|a| a.reviewers.find_or_create_by(committee_score: true)}.each do |application_reviewer|
        application_reviewer.update(finalized: true) if application_reviewer.started_scoring? && !application_reviewer.finalized?
      end
    end
    flash[:notice] = "Thank you! Your finalized scores were submitted."
    redirect_to :action => "index"
  end

  
  protected
  
  def add_committee_breadcrumbs
    add_breadcrumb "Committee Decisions", review_committee_path    
  end
  
  def fetch_application_reviewer    
    @application_reviewer = @app.reviewers.find_or_create_by(committee_score: true)
    @application_reviewer.create_scores
  end

  private
  def application_reviewer_params
    params.require(:application_reviewer).permit(:application_review_decision_type_id, :feedback_person_id, :finalized, :committee_score, :comments, score_attributes: [:id, :score, :comments])
  end
    
end