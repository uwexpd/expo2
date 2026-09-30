require "timeout"

desc "Daily sync Community Engaged course roster to UW GivePuse."
task :givepulse_roster_sync => :environment do
  start_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  puts "=== #{start_time} : START givepulse_roster_sync ==="
  
  sync_quarters = [Quarter.current_quarter, Quarter.current_quarter.next]
  # E Designated Courses are tracking-only and are imported once, not daily.
  excluded_group_ids = Rails.env.production? ? ["2173735"] : ["948128"]


  puts "#{sync_quarters.collect(&:title)} Course roster sync starts..."

  # Pick correct token depending on environment
  token_key = Rails.env.production? ? "GIVEPULSE_PRO_TOKEN" : "GIVEPULSE_BASIC_TOKEN"
  token     = ENV[token_key]

  if token.blank?
    puts "Missing #{token_key} in ENV. Aborting."
    exit 1
  # else
  #   token_preview = token[0..8] + "..."
  #   puts "#{token_key} is present: #{token_preview} (length=#{token.length})"
  end
  
  # Get GP CE courses with sync quarters:
  sync_quarters.each do |quarter|
      puts "Running GivepulseCourse.where(term: #{quarter.title.inspect})"
      ce_courses = GivepulseCourse.where(term: quarter.title)

      if ce_courses.none?
        puts "No courses found for #{quarter.title}"
        next
      end

      puts "Found #{ce_courses.count} courses in #{quarter.title}:  #{ce_courses.collect(&:crn).join(', ')}"

      ce_courses.each do |gp_course|
        crn = gp_course.crn.presence || "(blank CRN)"        
        
        if excluded_group_ids.include?(gp_course.parent_givepulse_id.to_s)
          puts "Skipping #{crn} (group id: #{gp_course.group_id}): E Designated Courses tracking-only group."
          next
        end

        unless gp_course.course.present?
          puts "Skipping #{crn} (group id: #{gp_course.group_id}): no associated SDB course found."
          next
        end

        begin
          puts "Sync starting #{crn} (group id: #{gp_course.group_id}): students"
          Timeout.timeout(120, GivepulseSyncTimeout) do
            gp_course.sync_course_students
          end

          puts "Sync finished #{crn} (group id: #{gp_course.group_id}): students; starting instructors"
          Timeout.timeout(120, GivepulseSyncTimeout) do
            gp_course.sync_course_instructors
          end

          student_count = gp_course.course_students.count
          instructors = gp_course.instructors.flatten.filter_map(&:fullname).uniq
          puts "Successfully synced #{crn}: #{student_count} students, instructors: #{instructors}"
          #puts "Successfully synced #{crn}: students and instructors"
        rescue GivepulseSyncTimeout => e
          Rails.logger.error("GivePulse sync timed out for #{crn} (group id: #{gp_course.group_id}): #{e.message}")
          puts "ERROR: timed out syncing #{crn} (group id: #{gp_course.group_id}); continuing."
        rescue StandardError => e
          Rails.logger.error(
            "GivePulse sync failed for #{crn} (group id: #{gp_course.group_id}): " \
            "#{e.class}: #{e.message}\n#{e.backtrace.join("\n")}"
          )
          puts "ERROR: failed syncing #{crn} (group id: #{gp_course.group_id}): #{e.class}: #{e.message}; continuing."
        end
      end
    end

  puts "=== #{Time.current.strftime('%Y-%m-%d %H:%M:%S')} : END givepulse_roster_sync ==="

end

class GivepulseSyncTimeout < Timeout::Error; end

# Bulk-import currently enrolled students into a GivePulse group.
#
# Usage:
#   rake givepulse:import_enrolled_students[765297,1,09-30-2026]
#   rake givepulse:import_enrolled_students[765297,1,09-30-2026,true]   # dry run
#
# Args:
#   group_id     - GivePulse group id (required)
#   branch       - campus branch, defaults to 1 (Bothell)
#   enrolled_on  - date passed to StudentRecord.current_enrolled, defaults to today
#   dry_run      - "true"/"1" to simulate the import without calling the
#                  GivePulse API or changing any group membership. Every
#                  student is evaluated (email/domain checks, admin field
#                  building) and logged as [DRY RUN] would_add / would_skip,
#                  but no POST /users request is made. Defaults to false.
#   limit        - optional Integer. When present, only the first N enrolled
#                  students (after fetch) are processed. Intended for quick
#                  smoke-testing (e.g. limit=25) before running against the
#                  full 6,000+ roster. Defaults to no limit (process all).
#
# Note: StudentRecord.current_enrolled(branch, enrolled_on) returns a plain
# Array<StudentRecord> (not an ActiveRecord::Relation), so this task loads
# the full set into memory (fine for ~6,000+ rows) and processes it in
# slices purely for progress logging / potential future throttling.
#
# Duplication safety: GivePulse's POST /users is a create-or-update keyed on
# email, so re-running this task never creates duplicate accounts — existing
# users just get their admin fields refreshed and group membership confirmed.
# GivepulseUser.add_student also rejects any non-uw.edu email before calling
# the API, so this import can never touch a non-UW GivePulse member (e.g. a
# community partner) even if bad SDB data slipped through.
desc "Import currently enrolled students into a GivePulse group"
task :givepulse_import_enrolled_students, [:group_id, :branch, :enrolled_on, :dry_run, :limit] => :environment do |_t, args|
  group_id    = args[:group_id]&.to_i
  branch      = (args[:branch] || 1).to_i
  enrolled_on = args[:enrolled_on] || Date.current.strftime('%m-%d-%Y')
  dry_run     = %w[true 1 yes].include?(args[:dry_run].to_s.strip.downcase)
  limit       = args[:limit].present? ? args[:limit].to_i : nil
  batch_size  = 200

  if group_id.blank?
    abort("Usage: rake givepulse:import_enrolled_students[group_id,branch,enrolled_on,dry_run]")
  end

  started_at   = Time.current
  added        = 0
  skipped      = 0
  non_uw_email = 0
  errored      = 0
  processed    = 0

  puts "Starting import for group_id=#{group_id} branch=#{branch} enrolled_on=#{enrolled_on}" \
         "#{' [DRY RUN — no changes will be made]' if dry_run}#{" [LIMIT #{limit}]" if limit}"

  # Fetch existing GivePulse group members once so we don't flip existing
  # users to private, and don't refetch per student. Also gives us an
  # up-front count of how many members are already in the group.
  existing_members = GivepulseUser.where(group_id: group_id)
  existing_emails   = existing_members.filter_map { |u| u.email.to_s.strip.downcase.presence }.to_set

  puts "Existing members currently in group #{group_id}: #{existing_members.size} (#{existing_emails.size} with usable emails)"

  student_records = Array(StudentRecord.current_enrolled(branch, enrolled_on))
  puts "Fetched #{student_records.size} enrolled StudentRecords."

  if limit
      student_records = student_records.last(limit)
      puts "Limiting run to last #{student_records.size} records."
  end

  student_records.each_slice(batch_size) do |slice|
    slice.each do |record|
      if record.nil? || record.email.blank?
        Rails.logger.warn("Skipping StudentRecord (id: #{record.try(:id)}) — no email on file.")
        skipped += 1
        processed += 1
        next
      end

      # StudentRecord already has everything add_student needs (firstname,
      # lastname, email, dir_release, major_branch_list, and #sdb returning
      # self), so it's passed directly — no need to resolve a separate
      # Student association here.
      result = GivepulseUser.add_student(
        record,
        group_id: group_id,
        existing_emails: existing_emails,
        dry_run: dry_run
      )

      case result[:status]
      when :added, :would_add
        added += 1
      when :skipped, :would_skip
        result[:reason] == 'non_uw_email' ? non_uw_email += 1 : skipped += 1
      when :error
        errored += 1
      end

      processed += 1
    end

    puts "  ...processed=#{processed}/#{student_records.size} added=#{added} skipped=#{skipped} non_uw_email=#{non_uw_email} errored=#{errored}"
  end

  duration = (Time.current - started_at).round(2)
   summary = "Import complete for group_id=#{group_id}, branch=#{branch}, enrolled_on=#{enrolled_on}" \
              "#{' [DRY RUN — no changes were made]' if dry_run}#{" [LIMIT #{limit}]" if limit} — " \
              "existing_members_before_import: #{existing_members.size}, processed: #{processed}, added: #{added}, " \
              "skipped: #{skipped}, non_uw_email: #{non_uw_email}, errored: #{errored}, duration: #{duration}s"

  Rails.logger.info(summary)
  puts summary
end


desc "Quarterly sync all users admin fields to UW Givepulse in batches."
task givepulse_users_sync: :environment do
  started_at = Time.now
  puts "=== #{started_at.strftime("%Y-%m-%d %H:%M:%S")} : START User Sync ==="
  Rails.logger.info("Starting Givepulse user sync at #{started_at}")

  group_id = Rails.env.production? ? "1246545" : "757578"
  offset = (ENV["OFFSET"] || 0).to_i
  limit  = (ENV["LIMIT"]  || 200).to_i
  effective_limit = [limit.to_i, 50].min # Givepulse caps at 50 currently
  
  puts "Params: group_id=#{group_id} offset=#{offset} limit=#{limit} effective_limit=#{effective_limit}"
  Rails.logger.info("Params: group_id=#{group_id} offset=#{offset} limit=#{limit} effective_limit=#{effective_limit}")

  batch_num = 0
  total_processed = 0
  total_updated = 0

  loop do
    batch_num += 1
    result = GivepulseUser.sync_group_members(group_id, offset: offset, limit: effective_limit)

    puts "[batch #{batch_num}] #{result[:message]}"
    Rails.logger.info("[batch #{batch_num}] #{result[:message]}")

    processed = result[:processed].to_i
    total     = result[:total].to_i

    total_processed += processed
    total_updated   += result[:updated].to_i

    break if processed == 0
    break if total > 0 && (offset + processed) >= total

    offset += processed
  end
rescue StandardError => e
  msg = "Error during Givepulse user sync: #{e.class}: #{e.message}"
  puts msg
  Rails.logger.error("#{msg}\n#{e.backtrace.join("\n")}")
ensure
  ended_at = Time.now
  duration = (ended_at - started_at).round(2)
  puts "=== #{ended_at.strftime("%Y-%m-%d %H:%M:%S")} : END User Sync ==="
  puts "Completed Givepulse user sync at #{ended_at}, duration: #{duration}s processed=#{total_processed} updated=#{total_updated}"
end


desc 'Fetch courses from PROD and create them in DEV'
task givepulse_import_courses: :environment do

  allowed_fields = %i[
    crn term subj_code crse_num crse_title crse_desc section cross_list_code 
    dept_code crse_dept_desc crse_coll_code crse_coll_desc
    class_time class_type class_status sl_type 
    faculty_id faculty2_id faculty3_id
  ]
  # parent_givepulse_id givepulse_organizer_id

  current_quarter = Quarter.current_quarter
  puts "Fetching courses from PROD for term #{current_quarter.title}..."

  # --- Step 1: Fetch from PROD ---
  GivepulseCourse.setup_authorization(
    custom_site: "https://api2.givepulse.com",
    custom_basic_token: ENV["GIVEPULSE_PRO_TOKEN"]
  )

  GivepulseUser.setup_authorization(
    custom_site: "https://api2.givepulse.com",
    custom_basic_token: ENV["GIVEPULSE_PRO_TOKEN"]
  )

  # prod_courses = GivepulseCourse.where(term: current_quarter.title, crn: 'CSS 295 A')
  prod_courses = GivepulseCourse.where(term: current_quarter.title, limit: 50)
  if prod_courses.blank?
    puts "No PROD courses found for term #{current_quarter.title}"
    next
  end

  puts "Found PROD courses: #{prod_courses.collect(&:crn).join(', ')} in #{current_quarter.title}"

  # --- Step 2: Import into DEV ---
  GivepulseCourse.setup_authorization(
    custom_site: "https://api2-dev.givepulse.com",
    custom_basic_token: ENV["GIVEPULSE_BASIC_TOKEN"]
  )  

  puts "Creating courses in DEV..."

  prod_courses.each_with_index do |course, idx|

    puts "DEBUG course #{idx+1} (#{course.crn}): #{course.inspect}"
    # Build payload from course attributes
    payload = course.instance_values.symbolize_keys.slice(*allowed_fields)
      
    campus_ids =  { 1479590 => 0, 1479577 => 1, 1480803 => 2, 792610 => 0, 792620 => 1, 811201 => 2 }
    
    branch_code = campus_ids[course.parent_givepulse_id]

    puts "DEBUG course branch_code #{idx+1} (#{course.crn}): #{branch_code}"
    payload[:parent_givepulse_id] = campus_ids.invert[branch_code]

    prod_organizer_email = GivepulseUser.find_by(user_id: course.givepulse_organizer_id).email rescue nil

    if prod_organizer_email
      GivepulseUser.setup_authorization(
        custom_site: "https://api2-dev.givepulse.com",
        custom_basic_token: ENV["GIVEPULSE_BASIC_TOKEN"]
      )

      payload[:givepulse_organizer_id] = GivepulseUser.find_by(email: prod_organizer_email).id.to_s rescue nil
    end    

    puts "DEBUG payload #{idx+1} (#{course.crn}): #{payload.inspect}"

    if payload[:crn].blank? || payload[:term].blank?
      puts "Skipping course #{course.crn}: Missing required fields"
      next
    end

    # Check if course already exists in DEV
    existing = GivepulseCourse.where(term: payload[:term].strip, crn: payload[:crn].strip)
    if existing.any?
      puts "Skipping course #{course.crn}: #{payload[:crn]} - #{payload[:term]} already exists in DEV"
      next
    end

    begin
      puts "Start importing a course #{course.crn}..."
      response = GivepulseCourse.request_api("/course", payload, method: :post)
      #puts "DEBUG response: #{response.inspect}"
      response_body = JSON.parse(response.body) rescue {}
      #puts "DEBUG response_body: #{response_body.inspect}"

      if response.code.to_i == 200 || response_body['total'].to_i > 0
        Rails.logger.info("✔ Successfully created course: #{payload[:crn]}, Group ID: #{response_body.dig('results', 0, 'group_id')}")
      else
        Rails.logger.error("Failed to create course #{payload[:crn]}. Response code: #{response.code}, Body: #{response_body}")
      end
    rescue StandardError => e
      Rails.logger.error("Exception creating course #{payload[:crn]}: #{e.message}")
    end
  end

  puts "Import completed."
end
