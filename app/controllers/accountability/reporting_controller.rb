class Accountability::ReportingController < AccountabilityController
  before_action :login_required
  before_action :add_reporting_breadcrumbs
  
  before_action :check_department_authorizations
  before_action :fetch_department, :except => [:choose_department]
  before_action :fetch_year_and_related, :except => [:choose_department]
  before_action :fetch_service_learning_courses, :only => [:index]  

  def index
    #Rails.logger.debug "department: #{@department.inspect}"
        
    @course_activity_type_ids = ActivityCourse.for_quarter_and_department(@quarters, @department).collect(&:activity_type_id)
    @individual_activity_type_ids = ActivityProject.for_quarter(@quarters).for_department(@department).collect(&:activity_type_id)        
  end

  def individuals
  end
  
  def summary
  end
  
  def restricted    
  end
  
  def choose_department
    if params[:accountability_department_authid]
      session[:accountability_department_authid] = params[:accountability_department_authid]      
      redirect_to action: 'index' and return
    end
  end
  
  
  # Confirm data has been entered by department. This will send email notification to department's all accountability coordinators and acctblty admin.
  def submit
    if params[:commit] == "Submit"
        template = EmailTemplate.find_by_name("accountability department data submit notification")
        admin_template = EmailTemplate.find_by_name("accountability department data submit notification for admin")
        @reportor_info = { :submitted_person => @my.person, :department => @department }
        
        dept_coordinators = @department.accountability_coordinator_authorizations.collect(&:user).reject{|u| u.login =="acctblty"}.uniq

        # dept_coordinators.each do |dept_coordinator|                    
        #   unless dept_coordinator.person.email.blank?
        #      @reportor_info[:dept_coordinator] = dept_coordinator.person             
        #      if template
        #         EmailContact.log(
        #           dept_coordinator.person,
        #           TemplateMailer.text_message(
        #             template.create_email_to(
        #             @reportor_info,
        #             "http://#{Rails.configuration.constants['base_url_host']}/accountability/reporting/#{@year}",
        #             dept_coordinator.person.email)
        #           ).deliver_now
        #         )
        #       end
        #   end
        # end
        TemplateMailer.admin_template.create_email_to(@reportor_info, "", "acctblty@uw.edu").deliver_now if admin_template
        flash[:notice] = "You've successfully submit the data. An email notification will be sent to all coordinators and our accountability administrator."
    else
      flash[:notice] = "You've saved the data. Please submit for your department after all accountability data has been entered."
    end    

    redirect_to action: "index"
  end
  
  protected
  
  def check_department_authorizations
    @my = current_user
    @department_authorizations = @my.authorizations_for(:accountability_department_coordinator)
    # return render :action => "restricted" if @department_authorizations.nil? || @department_authorizations.empty?
    render action: "restricted" if @department_authorizations.blank?
  end
  
  def fetch_department
    unless session[:accountability_department_authid]
      if @department_authorizations.size == 1
        session[:accountability_department_authid] = @department_authorizations.first.id
      else
        redirect_to action: "choose_department" and return
      end
    end
    @department = @department_authorizations.find{|a| a.id == session[:accountability_department_authid].to_i }.authorizable rescue nil
    return redirect_to :action => "choose_department" if @department.nil?
  end

  def fetch_year_and_related
    @year = params[:year].to_i.zero? ? Time.current.year : params[:year].to_i
    @quarter_abbrevs = ["SUM#{@year-1}", "AUT#{@year-1}", "WIN#{@year}", "SPR#{@year}"]
    @last_years_quarter_abbrevs = ["SUM#{@year-2}", "AUT#{@year-2}", "WIN#{@year-1}", "SPR#{@year-1}"]
    @quarters = Quarter.find_by_abbrev(@quarter_abbrevs)
    @last_years_quarters = Quarter.find_by_abbrev(@last_years_quarter_abbrevs)
    @activity_types = ActivityType.all
    @accountability_reports = {}
    @activity_types.each do |activity_type|
      ar = AccountabilityReport.find_or_create_by(
        year: @year,
        quarter_abbrevs: @quarter_abbrevs.join(" "),
        activity_type_id: activity_type.id
      )
      @accountability_reports[activity_type.id] = ar
    end
    @finalized = @accountability_reports.values.any?(&:finalized) # just say everything's final, even if one isn't.
    # @finalized = @accountability_reports.values.collect(&:finalized).include?(true) # just say everything's final, even if one isn't.
    add_breadcrumb @year.to_s, accountability_reporting_path(year: @year)
  end

  # Display the totals by courses for ServiceLearningPlacement in a specific department
  def fetch_service_learning_courses    
    @service_learning_courses ||= {}
    @service_learning_courses_total = 0
    @activity_types.each{|a| @service_learning_courses[a.id] ||= {}; @quarters.each{|q| @service_learning_courses[a.id][q.id] ||= [] } }
    activity_type_id = ActivityType.find_by(title: "Public Service")&.id
    
    @accountability_report = AccountabilityReport.find_by(
      year: @year,
      quarter_abbrevs: @quarter_abbrevs.join(" "),
      activity_type_id: activity_type_id
    )
    @report = @accountability_report.service_learning_course_statistics(@department) unless @accountability_report.in_progress?
    
    unless @report[:department]["#{@department.dept_code}_#{@department.name}"].blank?      
      for q in @quarters
          @service_learning_courses[activity_type_id][q.id] = @report[:department]["#{@department.dept_code}_#{@department.name}"][:quarters][q.abbrev][:courses] 
          @service_learning_courses_total += @service_learning_courses[activity_type_id][q.id].size
      end
    end
    
  end
  
  def check_finalized
    if @finalized
      flash[:error] = "You cannot report new information or make changes because this accountability report is finalized."
      redirect_back(fallback_location: root_path)
    end
  end
  
  def add_reporting_breadcrumbs
    add_breadcrumb "Accountability", accountability_path
    add_breadcrumb "Reporting", accountability_reporting_path(year: params[:year])
  end
  
end