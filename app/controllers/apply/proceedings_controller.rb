class Apply::ProceedingsController < ApplyController
  before_action :check_if_uses_proceedings
  
  skip_before_action :student_login_required_if_possible
  skip_before_action :fetch_user_applications, :choose_application, :redirect_to_group_member_area, :check_restrictions, :check_must_be_student_restriction, :display_submitted_note, :fetch_breadcrumb
  
  before_action :fetch_majors, :fetch_departments, :fetch_awards, :fetch_campus
  # before_action :fetch_favorite_abstracts

  before_action :add_header_details
  before_action :add_symposium_breadcrumb

  # cache_sweeper :application_for_offering_sweeper, :only => [ :result, :offering_session ]
  
  def index    
    @sessions = {}
    @offering.sessions.includes(application_type: :application_type).each do |s|
      @sessions[s.session_group] ||= {}
      @sessions[s.session_group][s.application_type.title] ||= []
      @sessions[s.session_group][s.application_type.title] << s
    end
    @sessions = @sessions.sort.to_h
      
    respond_to do |format|
      format.html
      # format.iphone
      # format.pdf if @current_user != :false && @current_user.admin?
    end
  end
  
  def show
    @app = @offering.application_for_offerings.find(params[:id])
    unless @app.passed_status?(:confirmed)
      flash[:error] = "That application is not yet confirmed. Please choose an application that is confirmed."
      return redirect_to :back
    end
    
    respond_to do |format|
      format.html
      # format.iphone
      # format.pdf if @current_user != :false && @current_user.admin?
    end
  end
  
  def result
    @query_strings = {}
    @result = []
    @result = find_by_student_name(params[:student_name]) unless params[:student_name].blank?
    @result = find_by_mentor_name(params[:mentor_name]) unless params[:mentor_name].blank?
    @result = find_by_department(params[:mentor_department]) unless params[:mentor_department].blank?
    @result = find_by_major(params[:student_major]) unless params[:student_major].blank?
    @result = find_by_award(params[:student_award]) unless params[:student_award].blank?
    @result = find_by_campus(params[:student_campus]) unless params[:student_campus].blank?
    @result = @result.uniq unless @result.empty?
    @result = @result.sort_by{|x| "#{x.offering_session.try(:session_group).to_s}#{x.offering_session.try(:identifier).to_s}"}
    

    merge_file = params[:header] == 'false' ? nil : @offering.proceedings_pdf_letterhead.try(:path)
    
    respond_to do |format|
      format.html
      format.iphone
      format.pdf { render :layout => 'proceedings', :merge_with => merge_file } if @current_user != :false && @current_user.admin?
    end
  end
  
  def offering_session
    add_breadcrumb "#{@offering.name} Schedules", @header_link
    @offering_session = @offering.sessions.find(params[:id])
    @presenters = @offering_session.presenters
    
    merge_file = params[:header] == 'false' ? nil : @offering.proceedings_pdf_letterhead.try(:path)
    
    respond_to do |format|
      format.html
      # format.iphone
      # format.pdf { render :layout => 'proceedings', :merge_with => merge_file } if @current_user != :false && @current_user.admin?
    end
  end
  
  def refresh_quotes
    return render nil unless %w(mentor_awards student_quotes).include?(params[:which])
    respond_to do |format|
      format.js
    end
  end
  
  def mentor_awards
    @quotes = Quote.key("proceedings_mentors_#{@offering.id.to_s}")
  end

  
  protected
  
  def check_if_uses_proceedings
    unless @offering.uses_proceedings?
      render :text => "This offering process does not use the Online Proceedings feature." and return
    end
  end
  
  def find_by_student_name(query)
    @query_strings[:student_name] = query
    result = []

    name_conditions = []; group_name_conditions = []
    query.split.each do |name_part|
      name_part = name_part.downcase.gsub(/\\/, '\&\&').gsub(/'/, "''").delete(",").delete(".").delete("%")
      name_conditions << "LOWER(people.firstname) LIKE '%#{name_part}%'"
      name_conditions << "LOWER(people.lastname) LIKE '%#{name_part}%'"
      group_name_conditions << "LOWER(application_group_members.firstname) LIKE '%#{name_part}%'"
      group_name_conditions << "LOWER(application_group_members.lastname) LIKE '%#{name_part}%'"
    end

    presenters = @offering.application_for_offerings.find :all, 
            :joins => [:person, {:current_application_status => :status_type }], 
            :include => [ :person ],
            :conditions => "name = 'confirmed' AND (#{name_conditions.join(" OR ")})",
            :order => "people.lastname, people.firstname"


    group_members = @offering.application_for_offerings.find :all, 
            :joins => [{:current_application_status => :status_type }], 
            :include => [{ :group_members => :person }],
            :conditions => "name = 'confirmed' AND (#{(name_conditions + group_name_conditions).join(" OR ")})",
            :order => "people.lastname, people.firstname"

    (presenters + group_members).uniq
  end

  def find_by_mentor_name(query)
    @query_strings[:mentor_name] = query
    result = []
    
    name_conditions = []
    # name_vars = []
    query.split.each do |name_part|
      name_part = name_part.downcase.gsub(/\\/, '\&\&').gsub(/'/, "''").delete(",").delete(".").delete("%")
      name_conditions << "LOWER(people.firstname) LIKE '%#{name_part}%'" 
      name_conditions << "LOWER(people.lastname) LIKE '%#{name_part}%'"
      # name_conditions << "LOWER(people.firstname) LIKE ?"
      # name_conditions << "LOWER(people.lastname) LIKE ?"
      # name_vars = name_vars << "%#{name_part}%" << "%#{name_part}%"
    end    
    #name_conditions = [name_conditions.join(" OR "), name_vars].flatten    
    mentors = @offering.application_for_offerings.find :all, 
            :joins => [{ :mentors => :person }, {:current_application_status => :status_type }],             
            :conditions => "name = 'confirmed' AND (#{name_conditions.join(" OR ")})",
            #:conditions => name_conditions,
            :order => "people.lastname, people.firstname"
  end

  def find_by_department(query)
    @query_strings[:mentor_department] = query
    result = @departments.values_at(query).flatten
    result = @offering.application_for_offerings.find_all_by_id(result).flatten
  end

  def find_by_major(query)
    @query_strings[:student_major] = query
    result = @majors.values_at(query).flatten.compact
    result = @offering.application_for_offerings.find_all_by_id(result).flatten
  end
  
  def find_by_award(query)
    @query_strings[:student_award] = query
    result = @awards.values_at(query).flatten
    result = @offering.application_for_offerings.find_all_by_id(result).flatten
  end

  def find_by_campus(query)
    @query_strings[:student_campus] = query
    result = @campus.values_at(query).flatten.compact
    result = @offering.application_for_offerings.find_all_by_id(result).flatten
  end
  
  # Fetches all primary presenters and group members in the confirmed status
  def fetch_applicants
    @apps ||= @offering.application_for_offerings.with_status(:confirmed)
    @all ||= (@apps + @apps.collect(&:group_members)).flatten.compact
    # @applicants ||= @all.collect(&:person).flatten.compact.uniq
  end
  
  def fetch_majors
    @majors = @offering.majors_mapping(:confirmed)
  end

  def fetch_departments
    @departments = @offering.departments_mapping(:confirmed, true).empty? ? @offering.departments_mapping(:confirmed) : @offering.departments_mapping(:confirmed, true)
  end
  
  def fetch_awards
    @awards = @offering.awards_mapping(:confirmed)
  end

  def fetch_campus
    @campus = @offering.campus_mapping(:confirmed)
  end
  
  def fetch_favorite_abstracts
    if logged_in?
      @favorite_abstracts = current_user.proceedings_favorites.for(@offering)
    else
      @favorite_abstracts = ProceedingsFavorite.find(:all, 
                              :conditions => { :session_id => request.session_options[:id] })
    end
    @favorite_abstract_ids = @favorite_abstracts.collect(&:application_for_offering_id).uniq
  end

  def add_header_details
    @header_link = apply_proceedings_path(@offering)
    @page_title_prefix = "#{@offering.title} Schedules"
    @hide_confidentiality_note = true
  end

  def add_symposium_breadcrumb
    unit = Unit.find_by_abbreviation('urp')
    add_breadcrumb "#{unit.name} Home", unit.home_url
  end
  
end
