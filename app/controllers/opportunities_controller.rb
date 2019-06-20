class OpportunitiesController < ApplicationController
	add_breadcrumb 'URP Home', Unit.find_by_abbreviation('urp').home_url
	
	invisible_captcha only: [:form], timestamp_enabled: false

  	before_action :login_required
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

		@research_opportunity = ResearchOpportunity.find(params[:id])
		if @research_opportunity
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

    def form
      add_breadcrumb "Research Opportunities Form", opportunity_form_path

      @research_opportunity = (ResearchOpportunity.find(params[:id]) if params[:id]) || ResearchOpportunity.new
    
      if @research_opportunity.submitted?
        flash[:notice] = "This research opportunity has been submitted."
        redirect_to :action => "submit", :id => @research_opportunity.id and return
      end
    
      if params[:research_opportunity]
        if @research_opportunity.update(opportunity_params)
           redirect_to :action => "submit", :id => @research_opportunity.id
        end
      end

    end  
  
    def submit
      add_breadcrumb "Research Opportunities Form", opportunity_form_path
      @research_opportunity ||= ResearchOpportunity.find(params[:id])         
      
      if request.patch?
	      if @research_opportunity.update(:submitted => true, :active => nil, :submitted_at => Time.now, :submitted_person_id => current_user.person.id)
	           flash[:notice] = "Successfully submitted a research opportunity and pleasa wait for URP staff approval."	         
	           urp_template = EmailTemplate.find_by_name("research oppourtunity approval request")
	           urp_template.create_email_to(@research_opportunity, "https://#{Rails.configuration.constants['base_app_url']}/admin/research_opportunities/#{@research_opportunity.id}", "urp@uw.edu").deliver_now
	      else
	        flash[:error] = "Something went wrong. Unable to submit research opportunity. Please try again."
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
  		params.require(:research_opportunity).permit(:name, :email, :department, :title, :description, :requirements, :research_area1, :research_area2, :research_area3, :research_area4, :end_date, :paid, :work_study, :location)
  	end

end