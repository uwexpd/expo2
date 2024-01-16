class OpportunitiesController < ApplicationController
  unit = Unit.find_by_abbreviation('urp')
	add_breadcrumb "#{unit.name} Home", unit.home_url
    skip_before_action :login_required, raise: false
    before_action :uw_netid_required_student_login_if_possible, :only => ['index', 'show']
    before_action :login_required, :only => ['research', 'form', 'submit']
    before_action :check_if_uwnetid, :only => ['index', 'show']

  def index
	    @search = ResearchOpportunity.active.ransack(params[:q])
	    @research_opportunities = @search.result(distinct: true).page(params[:page]).order('submitted_at DESC, name ASC')
	    
	    add_breadcrumb "Research Opportunities Search"
	end

	def show
    add_breadcrumb "Research Opportunities Search", opportunities_path
		
    @search = ResearchOpportunity.active.ransack(params[:q])		

		@research_opportunity = ResearchOpportunity.find(params[:id])
		if @research_opportunity
      		if !@research_opportunity.active? || (@research_opportunity.end_date && @research_opportunity.end_date < Date.today)
       			 flash[:error] = "The opportunity, #{@research_opportunity.title}, is inactive. You are not able to see more details."
        		redirect_to :action => "index"
      		end
      		add_breadcrumb @research_opportunity.title
    	else
      		flash[:error] = "Cannot find research opportunity id"
      		redirect_back(fallback_location: opportunities_path)
    	end	
	end

  def research
    add_breadcrumb "Research Opportunities Posting", opportunity_research_path

    @research_postings = ResearchOpportunity.where( submitted_person_id: current_user.person.id).order(:active)
    redirect_to :action => 'form' if @research_postings.blank?

  end

  def form
    add_breadcrumb "Research Opportunities Posting", opportunity_research_path
    add_breadcrumb "Research Opportunities Form"

    @research_opportunity = (ResearchOpportunity.find(params[:id]) if params[:id]) || ResearchOpportunity.new
  
    if @research_opportunity.submitted? && !@research_opportunity.active?
      flash[:notice] = "This research opportunity has been submitted."
      redirect_to :action => "submit", :id => @research_opportunity.id and return
    end
  
    if params[:research_opportunity]
      if @research_opportunity.update(opportunity_params)
         if params['commit'] == "Submit"
           if @research_opportunity.update(:active => true, :submitted_at => Time.now, :submitted_person_id => current_user.person.id)
          flash[:notice] = "Successfully resubmitted this research opportunity and notify URP staff."
          urp_template = EmailTemplate.find_by_name("research opportunity resubmitted notification")
          urp_template.create_email_to(@research_opportunity, "https://#{Rails.configuration.constants['base_app_url']}/admin/research_opportunities/#{@research_opportunity.id}", "urp@uw.edu").deliver_now
           else
              flash[:error] = "Something went wrong. Unable to submit research opportunity. Please try again."
           end
         else
            flash[:notice] = "Successfully save research opportunity and please make sure submit it."
         end
         redirect_to :action => "submit", :id => @research_opportunity.id
      end
    end

  end  
  
  def submit
    add_breadcrumb "Research Opportunities Posting", opportunity_research_path
    add_breadcrumb "Research Opportunities Submission"
    @research_opportunity ||= ResearchOpportunity.find(params[:id])
    unit = Unit.find_by_abbreviation('urp')
    
    if request.patch?
      if params['method'] == "remove"
        @research_opportunity.require_validations = false
        if @research_opportunity.update(:submitted => nil, :active => nil)
          urp_template = EmailTemplate.find_by_name("research opportunity deactivate notification")
          urp_template.create_email_to(@research_opportunity, "https://#{Rails.configuration.constants['base_app_url']}/admin/research_opportunities/#{@research_opportunity.id}", "urp@uw.edu").deliver_now
          flash[:notice] = "Successfully deactivated the opportunity and notified URP staff" and return
        else          
          flash[:error] = "Something went wrong. Unable to deactivate research opportunity. Please try again or contact #{unit.name} at #{unit.email}" and return
        end
      end

      if @research_opportunity.update(:submitted => true, :active => nil, :submitted_at => Time.now, :submitted_person_id => current_user.person.id)
          flash[:notice] = "Successfully submitted a research opportunity. You will receive URP staff approval shortly."
          urp_template = EmailTemplate.find_by_name("research opportunity approval request")
          urp_template.create_email_to(@research_opportunity, "https://#{Rails.configuration.constants['base_app_url']}/admin/research_opportunities/#{@research_opportunity.id}", "urp@uw.edu").deliver_now
      else
        flash[:error] = "Something went wrong. Unable to submit research opportunity. Please try again or contact #{unit.name} at #{unit.email}."
      end
     end
  end

	protected
  
  	def check_if_uwnetid
  		# logger.debug "Debug current_user => #{current_user}"
	    unless current_user.class.name == "PubcookieUser"
	      raise ExpoException.new("You need to have UW netid to access this page.",
	          "Please make sure you click on <strong>Sign in with UW NETID</strong> in the login page and access with your UW NetID. If you have any questions about this error message, please contact urp@uw.edu.")
	    end
  	end

  	private

  	def opportunity_params
  		params.require(:research_opportunity).permit(:name, :email, :department, :title, :description, :requirements, :research_area1, :research_area2, :research_area3, :research_area4, :end_date, :paid, :work_study, :location, :learning_benefit)
  	end

end