class Accountability::Reporting::CoursesController < Accountability::ReportingController
  before_action :add_courses_breadcrumbs
  before_action :check_finalized, only: %i[mass_add mass_create create update destroy]
  skip_before_action :fetch_service_learning_courses, except: :index

  def index
    @activities = {}
    @activity_types.each do |a|
      @activities[a.id] ||= {}
      @quarters.each { |q| @activities[a.id][q.id] ||= [] }
    end

    ActivityCourse.for_quarter_and_department(@quarters, @department).each { |a| @activities[a.activity_type_id][a.quarter_id] << a }

    @last_years_activities = {}
    @activity_types.each { |a| @last_years_activities[a.id] ||= [] }

    ActivityCourse.for_quarter_and_department(@last_years_quarters, @department).each { |a| @last_years_activities[a.activity_type_id] << a.course.short_title }
  end

  def mass_add
    raw_course_abbrevs = params[:course_abbrevs] || []
    unless raw_course_abbrevs.is_a?(Array)
      raw_course_abbrevs = raw_course_abbrevs.split(/[\n,]/).map(&:strip).reject(&:blank?).uniq
    end

    @courses = {}

    raw_course_abbrevs.each do |abbrev|
      match = Course.match(abbrev)
      result = {}

      if match.nil?
        result[:courses] = nil
        result[:message] = "Invalid format"
      else
        result[:courses] = {}

        courses = Course.find_all_by_short_title(
          match[1],          # dept_abbrev / short_title
          match[2],          # course_no
          @quarters,         # quarters
          section_id: match[3]
        )

        courses.each do |course|
          result[:courses][course.short_title] ||= {}
          result[:courses][course.short_title][course.quarter] = course
        end

        result[:courses] = result[:courses].sort_by { |k, _| k }.to_h
      end

      @courses[abbrev] = result
    end

    add_breadcrumb "Mass Add"    
  end

  def mass_create
    @success = []
    @errors  = []
    @dupes   = []

    Array(params[:course_ids]).each do |course_id|
      course = Course.find_by(id: course_id)
      next unless course

      attributes = {
        department_id: course.department&.id,
        title: course.course_title,
        quarter_id: course.quarter.id,
        course_branch: course.course_branch,
        course_no: course.course_no,
        dept_abbrev: course.dept_abbrev,
        section_id: course.section_id,
        preparer_uw_netid: current_user.login,
        activity_type_id: params[:activity_type_id]
      }

      if !@department.is_a?(Department) || @department.id != course.department&.id
        if @department.dept_code.present?
          attributes[:reporting_department_id] = @department.dept_code
        else
          attributes[:reporting_department_name] = @department.fixed_name
        end
      end

      if @accountability_reports[params[:activity_type_id].to_i]&.finalized?
        @errors << course
        next
      end

      activity = ActivityCourse.new(attributes)
      activity.save ? @success << activity : @errors << activity
    end

    respond_to do |format|
      format.html { redirect_to action: :index }
      format.js
    end
  end

  def create
    @activity = ActivityCourse.new(activity_params)
    raise "Access denied" unless @activity.belongs_to_department?(@department)

    respond_to do |format|
      if @activity.save
        flash[:notice] = "ActivityCourse was successfully created."
        format.html { redirect_to @activity }
        format.xml  { render xml: @activity, status: :created }
        format.js
      else
        format.html { render :new }
        format.xml  { render xml: @activity.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    @activity = ActivityCourse.find(params[:id])
    raise "Access denied" unless @activity.belongs_to_department?(@department)

    respond_to do |format|
      if @activity.update(activity_params)
        flash[:notice] = "ActivityCourse was successfully updated."
        format.html { redirect_to @activity }
        format.xml  { head :ok }
        format.js
      else
        format.html { render :edit }
        format.xml  { render xml: @activity.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def destroy
    @activity = ActivityCourse.find(params[:id])
    raise "Access denied" unless @activity.belongs_to_department?(@department)

    @activity.destroy

    respond_to do |format|
      format.html { redirect_to admin_activities_url }
      format.xml  { head :ok }
      format.js
    end
  end

  protected

  def activity_params
    params.require(:activity).permit(
      :department_id,
      :title,
      :quarter_id,
      :course_branch,
      :course_no,
      :dept_abbrev,
      :section_id,
      :activity_type_id,
      :reporting_department_id,
      :reporting_department_name
    )
  end

  def add_courses_breadcrumbs
    add_breadcrumb "Courses", accountability_reporting_courses_path(@year)
  end
end