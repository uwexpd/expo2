require "roo"

class ActivityProjectUploadedFile
  def initialize(upload_file, department, year, quarters)
    @department = department
    @year = year
    @quarters = quarters

    @column_mapping = {}
    @column_mapping_errors = []
    @hours_attribute_name = "hours_per_week"

    if upload_file.is_a?(String)
      @filename = upload_file
    else
      ext = File.extname(upload_file.original_filename.to_s).downcase
      ext = ".xls" unless [".xls", ".xlsx"].include?(ext)

      @filename = "individuals_#{Time.current.to_i}#{ext}"
      @upload_file = upload_file
      save_to_file!
    end
  end

  def save_to_file!
    File.open(file_path(true), "wb") { |f| f.write(@upload_file.read) }
  end

  def file_path(create_if_needed = false)
    path = Rails.root.join(
      "files", "activity_sources", @year.to_s, @department.hash.to_s, @filename
    ).to_s

    FileUtils.mkdir_p(File.dirname(path)) if create_if_needed
    path
  end

  def filename
    @filename
  end

  def workbook
    return @workbook if defined?(@workbook)

    ext = File.extname(file_path).delete(".").downcase # "xls" or "xlsx"
    ext = "xls" unless %w[xls xlsx].include?(ext)

    @workbook = Roo::Spreadsheet.open(file_path, extension: ext)
  end

  def sheet
    @sheet ||= workbook.sheet(0)
  end

  def headings
    @headings ||= sheet.row(1).map { |v| v.to_s }
  end

  def column_mapping=(mapping)
    h =
      if mapping.respond_to?(:to_unsafe_h)
        mapping.to_unsafe_h
      elsif mapping.respond_to?(:to_h)
        mapping.to_h
      else
        {}
      end

    # normalize keys + values to strings
    @column_mapping = {}
    h.each do |k, v|
      @column_mapping[k.to_s] = v.to_s
    end
  end

  def column_mapping_id(field_name)
    headings.index(@column_mapping[field_name])
  end

  def column_mapping_errors
    @column_mapping_errors
  end

  def valid_column_mapping?
    @column_mapping_errors = []

    if @column_mapping.blank?
      headings_options.each { |h| @column_mapping_errors << h }
      return false
    end

    headings_options.each { |h| @column_mapping_errors << h if @column_mapping[h].blank? }

    @column_mapping_errors.delete("activity_type") if @column_mapping["activity_type_override"].present?
    @column_mapping_errors.empty?
  end

  def import_records!
    raise "Invalid column mapping" unless valid_column_mapping?

    @success = []
    @errors  = []

    Activity.transaction do
      2.upto(sheet.last_row) do |row_num|
        row = sheet.row(row_num)
        next if row.compact.blank?

        attributes = {}
        quarter_columns = {}

        headings_options.each do |heading|
          idx = column_mapping_id(heading)
          cell_value = idx.nil? ? nil : row[idx]

          if heading == "activity_type" || heading == "activity_type_override"
            if @column_mapping["activity_type_override"].present?
              attributes[:activity_type_id] = @column_mapping["activity_type_override"].to_i
            else
              v = cell_value
              unless v.blank?
                guess = ActivityType.where(
                  "title LIKE ? OR abbreviation = ?",
                  "%#{v}%",
                  v.to_s[0..0]
                ).first
                attributes[:activity_type_id] = guess&.id
              end
            end

          elsif heading == "student_id"
            val = cell_value.to_s.strip
            next if val.blank?

            student =
              if val.to_i != 0
                StudentRecord.find_by(student_no: val)
              else
                StudentRecord.find_by(uw_netid: val)
              end

            attributes[:system_key] = student&.system_key

          elsif heading.start_with?("hours_per_week_")
            quarter_columns[heading] = cell_value

          else
            attributes[heading] = cell_value
          end
        end

        attributes[:preparer_uw_netid] = User.current_user&.login

        if @department.is_a?(Department)
          attributes[:department_id] = @department.id
        elsif @department.is_a?(DepartmentExtra)
          if @department.dept_code.blank?
            attributes[:department_name] = @department.fixed_name
          else
            attributes[:department_id] = @department.dept_code
          end
        end

        activity = ActivityProject.create(attributes)

        if activity.valid?
          quarter_columns.each do |heading, value|
            next if value.blank?

            quarter_abbrev = heading.match(/^hours_per_week_(\w{3}\d{4})/)[1]
            quarter = Quarter.find_by_abbrev(quarter_abbrev)
            next if quarter.nil?

            activity.quarters.create(
              quarter_id: quarter.id,
              @hours_attribute_name => value
            )
          end
          @success << activity
        else
          @errors << row
        end
      end
    end

    [@errors, @success]
  end

  def hours_are_totals=(val)
    truthy = (val.to_s == "true" || val.to_s == "1")
    @hours_attribute_name = truthy ? "number_of_hours" : "hours_per_week"
  end

  def headings_options
    rh = %w[activity_type student_id title faculty_uw_netid faculty_name]
    @quarters.each { |q| rh << "hours_per_week_#{q.abbrev}" }
    rh
  end

  def best_guess_heading(heading)
    # normalized = heading.to_s.downcase.delete(" ").delete("_")
    s = heading.to_s.strip

    # Normalize for matching
    normalized = s.downcase.gsub(/[\s_\/-]+/, "") # remove spaces, underscores, slashes, dashes

    # Match hours-per-week quarter columns like:
    # "hours per week sum 2024", "Hours_per_week_AUT2025", "hours/week-spr2026"
    if normalized.start_with?("hoursperweek")
      # try to extract something like SUM2024 / AUT2024 / WIN2025 / SPR2025
      m = s.upcase.gsub(/[^A-Z0-9]/, "").match(/(SUM|AUT|WIN|SPR)\d{4}/)
      if m
        return "hours_per_week_#{m[0]}"
      end
    end
    
    case normalized
    when "studentnumber", "studentno", "uwnetid", "netid" then :student_id
    when "title", "projecttitle" then :title
    when "activitytype", "type" then :activity_type
    when "facultyuwnetid", "facultynetid" then :faculty_uw_netid
    when "facultymentorname", "facultymentor", "facultyname", "faculty" then :faculty_name
    end
  end

  def best_column_heading_match_for(heading_option)
    headings.select { |h| heading_option.to_s == best_guess_heading(h).to_s }
  end

end