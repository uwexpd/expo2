class AccountabilityController < ApplicationController
  skip_before_action :login_required  
  
  def index
    add_breadcrumb "Accountability", accountability_path
    @years = AccountabilityReport.years_with_finalized
    
    @students_data = []
    @student_quarters_data = []
    @hours_data = []
    
    @activity_types = ActivityType.all
    @draft_years = []
    
    @activity_types.each do |activity_type|
      students_data = { name: activity_type.title, data: [] }
      student_quarters_data = { name: activity_type.title, data: [] }
      hours_data = { name: activity_type.title, data: [] }

      @years.each do |year|
        quarter_abbrevs = ["SUM#{year - 1}", "AUT#{year - 1}", "WIN#{year}", "SPR#{year}"]
        ar = AccountabilityReport.find_or_create_by(
          year: year,
          quarter_abbrevs: quarter_abbrevs.join(" "),
          activity_type_id: activity_type.id
        )
        @draft_years << year unless ar.finalized

        totals = ar.final_statistics[:total]
        students_data[:data] << totals[:number_of_students]
        student_quarters_data[:data] << totals[:student_quarters]
        hours_data[:data] << totals[:number_of_hours]
      end

      @students_data << students_data
      @student_quarters_data << student_quarters_data
      @hours_data << hours_data
    end
  end

  def year
    @year = params[:id].to_i
    @quarter_abbrevs = ["SUM#{@year-1}", "AUT#{@year-1}", "WIN#{@year}", "SPR#{@year}"]
    @activity_types = ActivityType.all
    @reports = {}
    @report_objects = {}
    @activity_types.each do |activity_type|
      ar = AccountabilityReport.find_or_create_by(
        year: @year,
        quarter_abbrevs: @quarter_abbrevs.join(" "),
        activity_type_id: activity_type.id
      )
      @reports[activity_type] = ar.final_statistics unless ar.in_progress?
      @report_objects[activity_type] = ar
    end
    @colleges = {}
    @reports.each do |activity_type, report|
      report[:department].each do |department_id, results|
        m = department_id.match(/^([E\d]+)_(.+)/) rescue nil

        if m && m[1] != "0" && m[1] != "E"
          department = Department.find(m[1])
          college_name = department&.college&.name || "Other"
          department_name = department&.name || "Unknown"
        elsif m
          college_name = "Other"
          department_name = m[2]
        else
          college_name = "Other"
          department_name = "Unknown"
        end

        @colleges[college_name] ||= { department: {} }
        @colleges[college_name][:department][department_name] ||= {}
        @colleges[college_name][:department][department_name][activity_type] = results
      end
    end
    
    add_breadcrumb "Accountability", accountability_path
    add_breadcrumb "#{@year.to_s} Accountability Report"
    
    respond_to do |format|
      format.html
      format.xlsx { render xlsx: 'year', filename: "Accountability_Report_#{@year}.xlsx", locals: { hide_college_title: false } }
    end
  end
  
end