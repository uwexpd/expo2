# app/controllers/accountability/reporting/individuals_controller.rb
class Accountability::Reporting::IndividualsController < Accountability::ReportingController
  before_action :add_individuals_breadcrumbs
  before_action :check_finalized, :only => [:upload, :upload_map, :upload_create, :new, :create, :edit, :update, :destroy]
  skip_before_action :fetch_service_learning_courses

  def index
    @activities = {}

    @activity_types.each do |activity_type|
      @activities[activity_type.id] =
        ActivityProject.for_quarter(@quarters).for_department(@department).of_type(activity_type).includes(:quarters).to_a
    end
  end

  def upload
    add_breadcrumb "Upload"
  end

  def upload_map
    unless request.put?
      return redirect_to(action: :index)
    end

    unless params.dig(:upload, :file).present?
      flash[:error] = "You must choose a file to upload."
      return render :upload
    end

    @file = ActivityProjectUploadedFile.new(params[:upload][:file], @department, @year, @quarters)
    @file.contents

    add_breadcrumb "Upload"
  rescue Ole::Storage::FormatError
    flash[:error] = "Invalid file format. Please upload a Microsoft Excel file in 97-2003 format (.xls file extension)."
    redirect_to action: :upload
  end

  def upload_create
    @file = ActivityProjectUploadedFile.new(params[:filename], @department, @year, @quarters)
    @file.column_mapping   = params[:heading_map]
    @file.hours_are_totals = params[:hours_are_totals]

    if @file.valid_column_mapping?
      @errors, @success = @file.import_records!

      flash[:notice] = "Successfully added #{@success.size} record(s)." if @success.present?
      if @errors.present?
        flash[:error] = "Could not add these #{@errors.size} record(s): <ul>#{@errors.map { |r| "<li>#{r.join(', ')}</li>" }.join}</ul>"
      end

      redirect_to action: :index, success_ids: @success.map(&:id)
    else
      flash[:error] = "You must select a matching column in your upload file for all required fields. Please try again."
      render :upload_map
    end

    add_breadcrumb "Upload"
  end

  def show
    redirect_to action: :edit
  end

  def new
    @activity = ActivityProject.for_quarter(@quarters).for_department(@department).new
    add_breadcrumb "New"

    respond_to do |format|
      format.html
      format.xml { render xml: @activity }
    end
  end

  def edit
    @activity = ActivityProject.for_quarter(@quarters).for_department(@department).find(params[:id])
    add_breadcrumb @activity.id.to_s, accountability_reporting_individual_path(@year, @activity)
    add_breadcrumb "Edit"
  end

  def create
    attributes = activity_params.to_h

    # preserve existing behavior: write dept_code into department_id, else store name
    if @department.dept_code.present?
      attributes[:department_id] = @department.dept_code
    else
      attributes[:department_name] = @department.fixed_name
    end
    attributes[:preparer_uw_netid] = current_user.login

    @activity = ActivityProject.for_quarter(@quarters).for_department(@department).new(attributes)

    quarters_error = validate_quarters_presence

    respond_to do |format|
      if quarters_error.nil? && @activity.save
        upsert_quarter_hours!(@activity)

        flash[:notice] = "Activity for #{@activity.student.fullname} was successfully created."
        format.html { redirect_to accountability_reporting_individuals_path(@year, success_ids: [@activity.id]) }
        format.xml  { render xml: @activity, status: :created, location: accountability_reporting_individual_path(@year, @activity) }
      else
        @activity.errors.add(:base, quarters_error) if quarters_error
        format.html { render :new }
        format.xml  { render xml: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @activity = ActivityProject.for_quarter(@quarters).for_department(@department).find(params[:id])

    attributes = activity_params.to_h
    attributes[:preparer_uw_netid] = current_user.login

    respond_to do |format|
      if @activity.update(attributes)
        upsert_quarter_hours!(@activity)

        flash[:notice] = "Activity for #{@activity.student.fullname} was successfully updated."
        format.html { redirect_to accountability_reporting_individuals_path(@year) }
        format.xml  { head :ok }
      else
        format.html { render :edit }
        format.xml  { render xml: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @activity = ActivityProject.for_quarter(@quarters).for_department(@department).find(params[:id])
    @activity.destroy

    respond_to do |format|
      format.html { redirect_to accountability_reporting_individuals_path(@year) }
      format.xml  { head :ok }
      format.js
    end
  end

  def student_search
    val = params[:student_id].to_s.strip
    @student = nil

    if val.present?
      @student =
        begin
          if val.to_i.to_s == val && val.to_i != 0
            StudentRecord.find_by(student_no: val)
          else
            StudentRecord.find_by(uw_netid: val)
          end
        rescue StandardError
          nil
        end
    end

    respond_to do |format|
      format.js
    end
  end

  def individual_reporting_template
    respond_to do |format|
      format.xls { render action: "individual_reporting_template", layout: nil }
    end
  end

  protected

  def activity_params    
    params.require(:activity).permit(
      :system_key, 
      :activity_type_id,
      :title,
      :faculty_uw_netid,
      :faculty_name,
      :student_uw_netid,
      :student_no,
      :student_name,
      :department_id,
      :department_name,
      :preparer_uw_netid
    )
  end

  def quarter_hours_params    
    params.permit(quarter_hours: {})[:quarter_hours].to_h
  end

  def quarter_calculation_params    
    params.permit(quarter_calculation: {})[:quarter_calculation].to_h
  end

  def validate_quarters_presence
    vals = quarter_hours_params.values.map { |v| v.to_s.strip }.reject(&:blank?).uniq
    return "You must specify at least one quarter of involvement." if vals.empty?
    nil
  end

  def upsert_quarter_hours!(activity)
    @quarters.each do |quarter|
      hours_val = quarter_hours_params[quarter.id.to_s].to_s.strip
      next if hours_val.blank?

      aq = activity.quarters.find_or_create_by(quarter_id: quarter.id)

      attribute_to_update = quarter_calculation_params[quarter.id.to_s].presence || "number_of_hours"
      attribute_to_reset  = (attribute_to_update == "number_of_hours") ? "hours_per_week" : "number_of_hours"
     
      aq.update(attribute_to_update => hours_val, attribute_to_reset => nil)
    end
  end

  def add_individuals_breadcrumbs
    add_breadcrumb "Individuals", accountability_reporting_individuals_path(@year)
  end
  
end