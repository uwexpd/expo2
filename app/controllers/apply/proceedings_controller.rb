class Apply::ProceedingsController < ApplyController
  before_action :check_if_uses_proceedings
  
  skip_before_action :student_login_required_if_possible
  skip_before_action :fetch_user_applications, :choose_application, :redirect_to_group_member_area, :check_restrictions, :check_must_be_student_restriction, :display_submitted_note, :fetch_breadcrumb
  
  before_action :fetch_applicants, :fetch_majors, :fetch_departments, :fetch_awards, :fetch_campus, :fetch_locations, :fetch_application_category
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
    add_breadcrumb "#{@offering.name} Schedules", @header_link
    @query_strings = {}    
    @result = @apps

    # Subqueries to stimulate interseciton in SQL for MySQL.
    @result = @result.where(id: find_by_student_name(params[:student_name]).select(:id)) unless params[:student_name].blank?
    @result = @result.where(id: find_by_major(params[:student_major]).select(:id)) unless params[:student_major].blank?
    @result = @result.where(id: find_by_application_category(params[:application_category]).select(:id)) unless params[:application_category].blank?
    @result = @result.where(id: find_by_award(params[:student_award]).select(:id)) unless params[:student_award].blank?
    @result = @result.where(id: find_by_campus(params[:student_campus]).select(:id)) unless params[:student_campus].blank?
    @result = @result.where(id: find_by_locations(params[:session_location]).select(:id)) unless params[:session_location].blank?
    @result = @result.where(id: find_by_mentor_name(params[:mentor_name]).select(:id)) unless params[:mentor_name].blank?
    @result = @result.where(id: find_by_department(params[:mentor_department]).select(:id)) unless params[:mentor_department].blank?

    @result = @result.joins(:offering_session).order("offering_sessions.session_group, offering_sessions.identifier")

    merge_file = params[:header] == 'false' ? nil : @offering.proceedings_pdf_letterhead.try(:path)
    
    respond_to do |format|
      format.html
      # format.iphone
      # format.pdf { render :layout => 'proceedings', :merge_with => merge_file } if @current_user != :false && @current_user.admin?
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
    return ApplicationForOffering.none if query.blank?

    name_parts = query.downcase.scan(/\w+/)
    return ApplicationForOffering.none if name_parts.empty?

    # Build SQL fragment and values for parameterized queries
    person_sql = name_parts.map { |part| "(LOWER(people.firstname) LIKE ? OR LOWER(people.lastname) LIKE ?)" }.join(" AND ")
    person_values = name_parts.flat_map { |part| ["%#{part}%", "%#{part}%"] }

    group_sql = name_parts.map { |part| "(LOWER(application_group_members.firstname) LIKE ? OR LOWER(application_group_members.lastname) LIKE ?)" }.join(" AND ")
    group_values = name_parts.flat_map { |part| ["%#{part}%", "%#{part}%"] }

    # Query presenter IDs
    presenter_ids = @offering.application_for_offerings
      .confirmed
      .joins(:person)
      .where(person_sql, *person_values)
      .pluck(:id)

    # Query group member IDs
    group_member_ids = @offering.application_for_offerings
      .confirmed
      .joins(group_members: :person)
      .where(group_sql, *group_values)
      .pluck(:id)

    result_ids = (presenter_ids + group_member_ids).uniq
    return ApplicationForOffering.none if result_ids.empty?

    ApplicationForOffering.where(id: result_ids)
    
  end

  def find_by_mentor_name(query)
    @query_strings[:mentor_name] = query
    return ApplicationForOffering.none if query.blank?

    terms = query.downcase.scan(/\w+/)
    return ApplicationForOffering.none if terms.empty?

    like_clauses = terms.flat_map do |term|
      [
        "LOWER(people.firstname) LIKE ?",
        "LOWER(people.lastname) LIKE ?"
      ]
    end

    values = terms.flat_map { |term| ["%#{term}%", "%#{term}%"] }

    @offering.application_for_offerings
             .confirmed
             .joins(mentors: :person)
             .where(like_clauses.join(' OR '), *values)
             .order('people.firstname, people.lastname')
  end

  def find_by_department(query)
    @query_strings[:mentor_department] = query
    result_ids = @departments.values_at(*query).flatten.compact
    ApplicationForOffering.where(id: result_ids)
  end

  def find_by_major(query)
    @query_strings[:student_major] = query
    result_ids = @majors.values_at(*query).flatten.compact
    ApplicationForOffering.where(id: result_ids)
  end
  
  def find_by_award(query)
    @query_strings[:student_award] = query
    result_ids = @awards.values_at(*query).flatten.compact
    ApplicationForOffering.where(id: result_ids)
  end

  def find_by_campus(query)
    @query_strings[:student_campus] = query
    result_ids = @campus.values_at(*query).flatten.compact
    ApplicationForOffering.where(id: result_ids)
  end

  def find_by_locations(query)
    @query_strings[:session_location] = query
    result_ids = @locations.values_at(*query).flatten.compact
    ApplicationForOffering.where(id: result_ids)
  end

  def find_by_application_category(query)
    @query_strings[:application_category] = query
    result_ids = @application_category.values_at(*query).flatten.compact
    ApplicationForOffering.where(id: result_ids)
  end
  
  # Fetches all primary presenters and group members in the confirmed status
  def fetch_applicants
    @apps ||= @offering.application_for_offerings.with_status(:confirmed).where(hide_proceeding_abstract: false)
    # @all ||= (@apps + @apps.collect(&:group_members)).flatten.compact
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

  def fetch_locations
    @locations = @offering.session_location_mapping(:confirmed)
  end

  def fetch_application_category
    @application_category = @offering.application_category_mapping(:confirmed)
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
