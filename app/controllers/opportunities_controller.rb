class OpportunitiesController < ApplicationController
	
	add_breadcrumb 'URP Home', Unit.find_by_abbreviation('urp').home_url
  
  	skip_before_action :login_required, :add_to_session_history
  	before_action :student_login_required_if_possible, :only => ['index', 'show'] # make sure first check if student role
  	before_action :check_if_uwnetid, :only => ['index', 'show']

  	def index	    
	    @search = ResearchOpportunity.active.ransack(params[:q])
	    @research_opportunities = @search.result.page(params[:page]).uniq.order('created_at DESC, name ASC')
	    
	    add_breadcrumb "Research Opportunities Search"
	end

	def show
		@search = ResearchOpportunity.active.ransack(params[:q])
		add_breadcrumb "Research Opportunities Search", opportunities_path

		if params[:id]
      		@research_opportunity = ResearchOpportunity.find params[:id]
      		if !@research_opportunity.active? || (@research_opportunity.end_date && @research_opportunity.end_date < Date.today)
       			 flash[:error] = "The opportunity, #{@research_opportunity.title}, is inactive. You are not able to see more details."
        		redirect_to :action => "search"
      		end
      		add_breadcrumb @research_opportunity.title
    	else
      		flash[:error] = "Cannot find research opportunity id"
      		redirect_to :back
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

end