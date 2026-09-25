# frozen_string_literal: true
#
# Preview:
#   bundle exec rake givepulse:import_activity_events FILE=tmp/Collab_Data_Test.xlsx DRY_RUN=true
#
# Import:
#   bundle exec rake givepulse:import_activity_events FILE=tmp/Collab_Data_Test.xlsx
#
# Preview or import one spreadsheet row (the header is row 1):
#   rake givepulse:import_activity_events FILE=tmp/Collab_Data_Test.xlsx ROW=2 DRY_RUN=true
#   rake givepulse:import_activity_events FILE=tmp/Collab_Data_Test.xlsx SHEET=2 ROW=2 DRY_RUN=true
#
# Optional fallback only for rows where `courses` is blank:
#   bundle exec rake givepulse:import_activity_events FILE=tmp/Collab_Data_Test.xlsx GROUP_ID=2019650
#
# A row with courses such as:
#   {"T NURS 414 A","T NURS 414 B","T NURS 414 D"}
# creates three events. Each course code is looked up with:
#   GivepulseCourse.where(term: "Autumn 2025", crn: "T NURS 414 A")
# and the matching course's group_id is used for that event.
#
# XLSX/XLS support requires: gem "roo"

require "csv"
require "json"
require "erb"
require "time"

namespace :givepulse do
  desc "Import Collab activities as GivePulse events, one event per listed course"
  task import_activity_events: :environment do
    file_path = ENV.fetch("FILE")
    fallback_group_id = ENV["GROUP_ID"].presence
    dry_run = ActiveModel::Type::Boolean.new.cast(ENV["DRY_RUN"])
    default_capacity = Integer(ENV.fetch("POSITIONS", "1"))

    abort "Spreadsheet not found: #{file_path}" unless File.file?(file_path)

    sheet = ENV.fetch("SHEET", "1").to_i
    rows = CollabActivityImport.load_rows(file_path, sheet: sheet)
    if ENV["ROW"].present?
      spreadsheet_row = ENV["ROW"].to_i
      rows = [rows.fetch(spreadsheet_row - 2)]
    end
    abort "No activity rows found in #{file_path}" if rows.empty?

    puts "Loaded #{rows.size} activity row(s).#{dry_run ? " DRY RUN: no events will be created." : ""}"

    succeeded = 0
    failures = []

    rows.each_with_index do |raw_row, index|
      row_number = index + 2
      row = CollabActivityImport.normalize_row(raw_row)
      title = CollabActivityImport.value_for(row, "activity_name")

      begin
        description = CollabActivityImport.value_for(row, "description")
        term = CollabActivityImport.value_for(row, "quarter")
        spreadsheet_group_id = CollabActivityImport.integer_for(row, "group_id").presence
        course_codes = CollabActivityImport.course_codes(row)
        missing = []
        missing << "activity_name" if title.blank?
        missing << "description" if description.blank?
        missing << "start_date" if CollabActivityImport.value_for(row, "start_date").blank?
        missing << "end_date" if CollabActivityImport.value_for(row, "end_date").blank?
        # Quarter is needed only when courses must be looked up for their group IDs.
        missing << "quarter" if spreadsheet_group_id.blank? && course_codes.any? && term.blank?
        raise ArgumentError, "missing #{missing.join(", ")}" if missing.any?

        start_time = CollabActivityImport.datetime_for(row, "start_date")
        end_time = CollabActivityImport.datetime_for(row, "end_date")
        raise ArgumentError, "end_date must be after start_date" if end_time <= start_time

        # A row-level group_id takes precedence over course codes. This creates
        # exactly one event in the supplied GivePulse group for that row.
        targets = if spreadsheet_group_id.present?
                    [{ code: nil, group_id: spreadsheet_group_id }]
                  elsif course_codes.any?
                    course_codes.map do |course_code|
                      course = GivepulseCourse.find_by(term: term, crn: course_code)
                      raise "GivePulse course not found for term '#{term}', CRN '#{course_code}'" unless course
                      raise "GivePulse course '#{course_code}' has no group_id" if course.group_id.blank?

                      { code: course_code, group_id: course.group_id }
                    end
                  elsif fallback_group_id.present?
                    [{ code: nil, group_id: fallback_group_id }]
                  else
                    raise ArgumentError, "group_id and courses are blank (supply GROUP_ID only if a fallback is intended)"
                  end

        targets.each do |target|
          params = {
            title: title,
            description: CollabActivityImport.description_for(row),
            group_id: target[:group_id],
            event_type: "event",
            num_registrants_needed: CollabActivityImport.integer_for(
              row, "num_registrants_needed", "positions_available", "capacity"
            ) || default_capacity,
            start_date_time: start_time,
            end_date_time: end_time,
            # Comment below to make it event organizer  default to course group organizer 
            # first_name: CollabActivityImport.value_for(row, "primary_contact_firstname"),
            # last_name: CollabActivityImport.value_for(row, "primary_contact_lastname"),
            # email: CollabActivityImport.value_for(row, "primary_contact_email"),
            address1: CollabActivityImport.value_for(row, "primary_site_address"),
            address2: CollabActivityImport.value_for(row, "primary_site_address2"),
            city: CollabActivityImport.value_for(row, "primary_site_city"),
            state: CollabActivityImport.value_for(row, "primary_site_state"),
            zip: CollabActivityImport.value_for(row, "primary_site_zipcode")&.sub(/\.0\z/, ""),
            website: CollabActivityImport.value_for(row, "website"),
            is_published: CollabActivityImport.boolean_string_for(row, "is_published", default: "0")
          }.compact

          if dry_run
            succeeded += 1
            target_name = target[:code] || (spreadsheet_group_id.present? ? "spreadsheet group_id" : "GROUP_ID fallback")
            puts "[DRY RUN] Row #{row_number}: #{title} -> #{target_name} (group #{target[:group_id]})"
            next
          end

          result = GivepulseEvent.create_event(params)
          raise "GivePulse API request failed" if result.blank?

          succeeded += 1
          event_id = result["event_id"] || result["id"] || "unknown"
           target_name = target[:code] || (spreadsheet_group_id.present? ? "spreadsheet group_id" : "GROUP_ID fallback")
          puts "Created row #{row_number}: #{title} -> #{target_name} (event #{event_id})"
        end
      rescue StandardError => e
        message = "Row #{row_number} (#{title || "untitled"}): #{e.message}"
        failures << message
        Rails.logger.error(message)
        warn message
      end
    end

    puts "\nImport complete: #{succeeded} succeeded, #{failures.size} failed."
    puts "Failures:\n- #{failures.join("\n- ")}" if failures.any?
    abort "Import completed with failures." if failures.any?
  end

  desc "Fetch Bothell Connected Huskies events JSON and create GivePulse events via API"
  task import_events: :environment do
    require 'faraday'
    require 'json'

    # Fetch events JSON data from UW
    response = Faraday.get('https://depts.washington.edu/uwbur/wp-json/export/v1/hp-listings')

    if response.status == 200
      parsed_json = JSON.parse(response.body)
      events_data = parsed_json["data"] || []
      puts "Fetched #{events_data.size} events."
    else
      puts "Failed to fetch events data: #{response.status}"
      exit 1
    end

    success_count = 0
    failure_count = 0
    failed_titles = []

    # Map and create each event
    events_data.each do |event|
      # puts "event data: #{event.inspect}"
      # Map fields from UW JSON to GivePulse API params
      full_params = {
        title: event['post_title'] || "No title",
        description: event['post_content'] || "",
        group_id: "2019650", # Connected Huskies Group ID: sandbox: "921813"
        event_type: "event",
        num_registrants_needed: 2,  # Adjust or map from event if available
        start_date_time: DateTime.new(2026, 1, 1, 0, 0, 0, "-08:00"),
        end_date_time:   DateTime.new(2026, 8, 21, 23, 59, 59, "-07:00"),
        first_name: "Sarah",
        last_name: "Verlinde-Azofeifa",
        email: "severlin@uw.edu",
        address1: event['address'],
        # address2: event['address2'],
        city:     event['city'],
        state:    event['state'],
        zip:      event['zip'],
        is_published: "0"
      }
      # puts "full_params: #{full_params.inspect}"

      # Create event via GivepulseEvent class method
      result = GivepulseEvent.create_event(full_params)

      if result
        success_count += 1
        puts "Created event: #{full_params[:title]}"
      else
        failure_count += 1
        failed_titles << full_params[:title]
        puts "Failed to create event: #{full_params[:title]}"
      end
    end

    puts "Import complete: #{success_count} succeeded, #{failure_count} failed."
    if failure_count > 0
      puts "Failed events: #{failed_titles.join(', ')}"
    end
  end

end # end givepulse namespace

module CollabActivityImport
  module_function

  # sheet is 1-based for command-line use: SHEET=2 selects the second tab.
  # CSV and TSV files have no worksheets, so they always load as a single sheet.
  def load_rows(file_path, sheet: 1)
    case File.extname(file_path).downcase
    when ".csv", ".tsv"
      content = File.read(file_path, encoding: "bom|utf-8")
      separator = content.lines.first.to_s.include?("\t") ? "\t" : ","
      CSV.parse(content, headers: true, col_sep: separator).map(&:to_h)
    when ".xlsx", ".xls"
      require "roo"

      sheet_number = Integer(sheet)
      raise ArgumentError, "SHEET must be 1 or greater" if sheet_number < 1

      workbook = Roo::Spreadsheet.open(file_path)
      if sheet_number > workbook.sheets.size
        raise ArgumentError,
              "Spreadsheet has only #{workbook.sheets.size} worksheet(s); SHEET=#{sheet_number} does not exist"
      end

      worksheet = workbook.sheet(sheet_number - 1)
      headers = worksheet.row(1)
      (2..worksheet.last_row).filter_map do |row_number|
        values = worksheet.row(row_number)
        next if values.all?(&:blank?)

        headers.zip(values).to_h
      end
    else
      abort "Unsupported file type. Use .csv, .tsv, .xlsx, or .xls."
    end
  rescue LoadError
    abort "XLSX/XLS import requires gem 'roo'. Add it to the Gemfile and run bundle install."
  end

  def normalize_row(raw_row)
    raw_row.each_with_object({}) do |(header, value), row|
      key = header.to_s.strip.downcase.gsub(/[()]/, " ").gsub(/[^a-z0-9]+/, "_").sub(/\A_+|_+\z/, "")
      row[key] = value
    end
  end

  def value_for(row, *keys)
    keys.each do |key|
      value = row[key]
      next if value.blank?

      text = value.to_s.strip
      next if text.blank? || %w[none null n/a].include?(text.downcase)

      return text
    end
    nil
  end

  def integer_for(row, *keys)
    value = value_for(row, *keys)
    value.to_i if value.present?
  end

  def boolean_string_for(row, *keys, default:)
    value = value_for(row, *keys)
    return default if value.blank?

    %w[1 true yes y].include?(value.downcase) ? "1" : "0"
  end

  def datetime_for(row, *keys)
    value = value_for(row, *keys)
    raise ArgumentError, "missing #{keys.first}" if value.blank?
    unless value.match?(/(?:z|[+-]\d{2}:?\d{2})\z/i)
      raise ArgumentError, "#{keys.first} must include a timezone: #{value}"
    end

    Time.parse(value)
  rescue ArgumentError => e
    raise e if e.message.start_with?(keys.first.to_s)

    raise ArgumentError, "invalid #{keys.first}: #{value}"
  end

  # Supports JSON arrays and Collaboratory's brace-and-quoted format:
  # {"T NURS 414 A","T NURS 414 B","T NURS 414 D"}
  def course_codes(row)
    raw = value_for(row, "courses")
    return [] if raw.blank?

    if raw.start_with?("[")
      JSON.parse(raw).map(&:to_s).map(&:strip).reject(&:blank?)
    else
      raw.scan(/"([^"]+)"/).flatten.presence || raw.tr("{}", "").split(",").map(&:strip).reject(&:blank?)
    end
  rescue JSON::ParserError
    raise ArgumentError, "invalid courses value: #{raw}"
  end

  def description_for(row)
    description = value_for(row, "description")
    metadata = {
      # "Activity Lead" => value_for(row, "activity_lead"),
      # "Activity Lead Email" => value_for(row, "activity_lead_email"),
      # "Activity Owner" => value_for(row, "activity_owner"),
      # "Activity Owner Email" => value_for(row, "activity_owner_email"),
      "Populations" => value_for(row, "populations"),
      # "Student Participation" => value_for(row, "student_members_student_participation"),
      # "Student Participation Hours" => value_for(row, "student_hours_student_participation_hours"),
      # "Faculty Participation" => value_for(row, "faculty_members_faculty_participation"),
      # "Section" => value_for(row, "section"),
      "Campus Partner" => value_for(row, "campus_partners"),
      "Community Organization Roles" => value_for(row, "community_org_roles_community_organization_roles"),
      # "Individuals Served" => value_for(row, "individuals_served"),
      # "Community Insight" => value_for(row, "community_insight"),
      # "Enrolled Student Participation" => value_for(row, "enrolled_student_participation_student_enrollment"),
      # "Enrolled Student Hours" => value_for(row, "enrolled_student_hours")
    } # .filter_map { |label, value| "#{label}: #{value}" if value.present? }

    # [description, ("Activity Details:\n#{metadata.join("\n")}" if metadata.any?)].compact.join("\n\n")

    detail_lines = metadata.filter_map do |label, value|
      next if value.blank?

      "<b>#{ERB::Util.html_escape(label)}:</b> #{format_metadata_value(value)}"
    end

    details = if detail_lines.any?
                "#{detail_lines.join("<br>")}"
              end

    [description, details].compact.join("<br><br>")
  end

  def format_metadata_value(value)
    text = value.to_s.strip

    # Collab exports multi-select values in forms such as {"Rural Communities"}.
    # Remove braces and quotes, then make multiple values readable on one line.
    text = text.gsub(/[{}]/, "").gsub('"', "")
    values = text.split(/\s*,\s*/).map(&:strip).reject(&:blank?)
    text = values.join("; ")

    number = Float(text)
    number % 1 == 0 ? number.to_i.to_s : number.to_s
  rescue ArgumentError, TypeError
    ERB::Util.html_escape(text)
  end
end
