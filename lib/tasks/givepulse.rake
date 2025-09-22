desc "Daily sync Community Engaged course roster to UW GivePuse."
task :givepulse_roster_sync => :environment do
  start_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  puts "=== #{start_time} : START givepulse_roster_sync ==="
  
  sync_quarters = [Quarter.current_quarter, Quarter.current_quarter.next]

  puts "#{sync_quarters.collect(&:title)} Course roster sync starts..."

  if ENV["GIVEPULSE_PRO_TOKEN"].blank?
    puts "Missing GIVEPULSE_PRO_TOKEN in ENV. Aborting."
    exit 1
  else
    token_preview = ENV["GIVEPULSE_PRO_TOKEN"][0..8] + "..."
    puts "GIVEPULSE_PRO_TOKEN is present: #{token_preview} (length=#{ENV["GIVEPULSE_PRO_TOKEN"].length})"
  end
  
  # Get GP CE courses with sync quarters:
  sync_quarters.each do |quarter|
      puts "Running GivepulseCourse.where(term: #{quarter.title.inspect})"
      ce_courses =  GivepulseCourse.where(term: quarter.title)

      if ce_courses.blank?
          puts "No courses found for #{quarter.title}"
      else
          puts "Found courses: #{ce_courses.collect(&:crn).join(', ')} in #{quarter.title}"

          ce_courses.each do |gp_course|

            if gp_course.course.blank?
              puts "Skipping #{gp_course.crn}: no associated SDB course found."
              next
            end
            gp_course.sync_course_students
            puts "Sucessfully synced #{gp_course.crn} #{gp_course.course_students.size} students."
            gp_course.sync_course_instructors
            puts "Sucessfully synced #{gp_course.crn} instructors: #{gp_course.instructors.flatten.collect(&:fullname).uniq}"
          end
      end
  end

  end_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
  puts "=== #{end_time} : END givepulse_roster_sync ==="
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
  prod_courses = GivepulseCourse.where(term: current_quarter.title)
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
