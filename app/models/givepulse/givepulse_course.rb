class GivepulseCourse < GivepulseBase
  include ActiveModel::Model

  # Attributes for the User
  attr_accessor :id, :crn, :term, :group_id, :subj_code, :crse_num, :crse_title, 
              :crse_desc, :parent_givepulse_id, :section, :cross_list_code, 
              :dept_code, :crse_dept_desc, :crse_coll_code, :crse_coll_desc, 
              :class_time, :class_type, :class_status, :sl_type, 
              :givepulse_organizer_id, :faculty_id, :faculty2_id, :faculty3_id

  CAMPUS_IDS_BY_ENV = {
    # Seattle Sync groups: Seattle CEC, E Designated Courses
    # Bothell Sync groups: Bothell CEC, School of Nursing & Health Studies, School of Educational Studies - Bothell
    # Tacoma  Sync gorups: Tacoma CEC, School of Education
    production: { 1479590 => 0, 2173735 => 0, 1479577 => 1, 1479583 => 1, 2172600 => 1, 1480803 => 2, 1968908 => 2 },
    sandbox:      { 792610 => 0, 948128 => 0, 792620  => 1, 788280 => 1, 945067 => 1, 811201 => 2,  921544 => 2}
  }.freeze

  # Example Use: GivepulseCourse.where(term: 'Autumn 2025' , crn: 'BHS496A')
  # GivepulseCourse.find_by(group_id: 788279)
  def self.where(attributes)
    begin
      results = fetch_all_records('/courses', attributes)
      results.map { |attrs| new(attrs.slice(*permitted_attrs)) }
    rescue StandardError => e
      Rails.logger.error("Error fetching courses: #{e.message}")
      []
    end
  end

  # Sync course students to GivePulse
  # If the student (email) exists, it will update the params in this case. [Tested]
  # Handle course droppers and mismatch. 
  def sync_course_students
    # Normalize for roster email comparison
    roster_entries = self.course_students.to_a
    sdb_emails = roster_entries.map do |entry|
      student = entry.is_a?(Array) ? entry.first : entry
      student.email&.downcase
    end.compact
    givepulse_students = self.givepulse_course_students || []
    givepulse_emails = givepulse_students.map { |u| u.email&.downcase }.compact
    
    # 1. Sync current students
    roster_entries.each do |entry|
      if entry.is_a?(Array)
        student, source_course = entry
        course_section = "#{source_course.short_title}"
      else
        student = entry
        course_section = nil
      end

      email = student.email&.downcase
      next unless email

      sdb_student = student.sdb
      admin_minor = sdb_student.age < 18 ? "Yes" : "No"
      admin_dir_release = student.dir_release ? "Yes" : "No"
      admin_campus = student.major_branch_list rescue ''
      admin_class_standing = sdb_student.class_standing_description(show_upcoming_graduation: true) rescue ''
      admin_student_major = sdb_student.majors_list(true, ", ") rescue ''
      admin_fields = if Rails.env.production?
        { "236072" => admin_minor, "236073" => admin_dir_release, "239467" => course_section, "268083" => admin_campus, "268084" => admin_class_standing, "268085" => admin_student_major, "276190" => Date.current.to_s }
      else
        { "81445" => admin_minor, "81773" => admin_dir_release, "82030" => course_section, "82591" => admin_campus, "82592" => admin_class_standing, "82593" => admin_student_major, "82641" => Date.current.to_s }
      end

      post_params = {
        user: {
         first_name: student.firstname,
         last_name: student.lastname,
         email: student.email,
         # student_id: student.email.email.sub(/@uw\.edu\z/, ''), 
         administrative_fields: admin_fields,
         group_id: self.group_id,         
        }
      }

      # Set is_private only if not in GivePulse
      unless givepulse_emails.include?(email)
        post_params[:user][:is_private] = 1
      end

      # Rails.logger.debug("Debug post_params => #{post_params}")
      begin
        response = GivepulseCourse.request_api("/users", post_params, method: :post)
        response_body = JSON.parse(response.body)
        # Rails.logger.debug("Sync Students Debug response => #{response}")
        if response.code.to_i == 200 || response_body["updated"] == true
          Rails.logger.info("Successfully synced student with ID: #{response_body['user_id']}")
        else
          Rails.logger.error("Failed to sync student #{student.email}. Response code: #{response.code}, Response body: #{response.body}")
        end
      rescue StandardError => e
        Rails.logger.error("Exception occurred while syncing student #{student.email}: #{e.message}")
      end
    end

    # 2. Find and remove droppers
    droppers = givepulse_students.reject do |gp_user|
      sdb_emails.include?(gp_user.email&.downcase)
    end
    Rails.logger.info("Droppers to be removed: #{droppers.size}")
    droppers.each do |dropper|

      drop_params = {
            email: dropper.email,
            course_id: self.id,
            delete: "yes"
      }

      # find droper's registrations and cancel them
      registraitons = GivepulseRegistration.where(user_id: dropper.id, group_id: self.group_id)

      # ---- Cancel registrations for this course ----
      cancelled_events = []
      if registraitons.present?
        registraitons.each do |registration|
          registration.cancel!(send_notification: true)
        end
        # Gather event titles for cancelled registrations                
        cancelled_events = registraitons.map { |registration| registration.try(:event)["title"]}.join(", ")

        # Call update_user method on the dropper after cancelling registrations
        # update admin archive require field to the course title
        dropper.update_user({
          user: {         
           administrative_fields: Rails.env.production? ? { "271861" => self.short_title} : { "82638" => self.short_title },
           group_id: self.group_id,
          }
        })
      end
      # ---- END Cancel ----

      begin
        Rails.logger.info("Removing dropper, #{dropper.email}, from the GivePulse course #{self.crn}")

        response = GivepulseCourse.request_api("/courseStudent", drop_params, method: :delete)
        #Rails.logger.debug("Debug response DELETE => #{response}")

        if response.code.to_i == 200
          Rails.logger.info("Successfully removed #{dropper.email} from GivePulse course #{self.crn}")
                     
          # Send email notification to the course admins in CCUW
          # Fetch course admins from Givepulse API
          course_admins = GivepulseUser.where(group_id: self.group_id, role: 'admin')

          # Exclude the admin with communityconnect@uw.edu
          course_admins.reject! { |admin| admin.email == 'communityconnect@uw.edu' }

          course_admins.each do |course_admin|
            link = Rails.env.production? ? "https://uw.givepulse.com/group/manage/users/#{self.group_id}" : "https://uw-dev.givepulse.com/group/manage/users/#{self.group_id}"            

            begin
              mail = CommunityEngagedMailer.templated_message(
                course_admin,
                EmailTemplate.find_by_name("ccuw course dropper notification"),
                course_admin.email,
                link,
                { student_name: "#{dropper.first_name} #{dropper.last_name}", student_email: dropper.email, cancelled_events: cancelled_events }
              ).deliver_now

              EmailContact.log(User.find_by_login('communityconnect').person.id, mail)
              
            rescue StandardError => e
              Rails.logger.error("Failed to send dropper notification email to #{course_admin.email}: #{e.message}")
              # Optionally: notify Sentry.
            end
          end

        else
          Rails.logger.error("Failed to remove #{dropper.email}. Code: #{response.code}, Body: #{response.body}")
        end

      rescue StandardError => e
        Rails.logger.error("Exception removing #{dropper.email}: #{e.message}")
      end
    end
  end

  # Add an entire course roster to GivePulse.
  #
  # For each student, create or update the user via POST /users.
  # Passing group_id is sufficient to add the student to the course group —
  # a separate /courseStudent call is not needed.
  #
  # Students missing an email are skipped and logged.
  # crn and term are taken from the course instance.
  #
  # @param students [Array<Student>] roster from sdb_course.all_enrollees
  # @param course_section [String, nil] optional cross-list section label
  # @return [Hash] { added: Integer, skipped: Integer }
  #
  # Example:
  #   course = GivepulseCourse.where(term: 'Spring 2026', crn: 'B ENGR 496 B').first
  #   course.add_students(sdb_course.all_enrollees, "B")
  def add_students(students, course_section = nil)
    added   = 0
    skipped = 0

    # Fetch existing GivePulse members once to determine is_private
    givepulse_students = self.givepulse_course_students || []
    givepulse_emails   = givepulse_students.map { |u| u.email&.downcase }.compact

    Array(students).each do |student|
      if student.email.blank?
        Rails.logger.warn("Skipping student (student_no: #{student.student_no}) — no email on file.")
        skipped += 1
        next
      end

      begin
        sdb_student          = student.sdb
        admin_minor          = sdb_student.age < 18 ? "Yes" : "No"
        admin_dir_release    = student.dir_release ? "Yes" : "No"
        admin_campus         = student.major_branch_list rescue ''
        admin_class_standing = sdb_student.class_standing_description(show_upcoming_graduation: true) rescue ''
        admin_student_major  = sdb_student.majors_list(true, ", ") rescue ''

        admin_fields = if Rails.env.production?
          { "236072" => admin_minor, "236073" => admin_dir_release, "239467" => course_section,
            "268083" => admin_campus, "268084" => admin_class_standing, "268085" => admin_student_major,
            "276190" => Date.current.to_s }
        else
          { "81445" => admin_minor, "81773" => admin_dir_release, "82030" => course_section,
            "82591" => admin_campus, "82592" => admin_class_standing, "82593" => admin_student_major,
            "82641" => Date.current.to_s }
        end

        user_params = {
          user: {
            first_name:            student.firstname,
            last_name:             student.lastname,
            email:                 student.email,
            administrative_fields: admin_fields,
            group_id:              self.group_id
          }
        }

        email = student.email.downcase

        # Only mark as private if the user doesn't already exist in GivePulse
        unless givepulse_emails.include?(email)
          user_params[:user][:is_private] = 1
        end

        user_response = GivepulseCourse.request_api("/users", user_params, method: :post)

        if user_response.is_a?(Hash)
          Rails.logger.error("Failed to add student #{student.email}. Error: #{user_response[:error] || user_response}")
          skipped += 1
          next
        end

        user_response_body = JSON.parse(user_response.body)

        unless user_response.code.to_i == 200 || user_response_body["updated"] == true
          Rails.logger.error("Failed to add student #{student.email}. Code: #{user_response.code}, Body: #{user_response.body}")
          skipped += 1
          next
        end

        Rails.logger.info("Successfully added #{student.email} to course #{self.crn} (user_id: #{user_response_body['user_id']})")
        added += 1

      rescue StandardError => e
        Rails.logger.error("Exception adding student #{student.email}: #{e.message}")
        skipped += 1
      end
    end

    Rails.logger.info("add_students complete for #{self.crn} — added: #{added}, skipped: #{skipped}")
    { added: added, skipped: skipped }
  end



  def quarter
    # Quarter.find_by_abbrev(self.term)
    # To be compatiable with Canvas: Term: "Summer 2025"
    Quarter.find_by_title(self.term)
  end


  # Branch/campus code: 0: Seattle, 1: Bothell, 2: Tacoma  
  # [TODO] We should add a custom field for this. There is external_id in GP we could use but it can be updated by admin users so not doing with that.
  def course
    return unless quarter
    
    Course.find_by(
      ts_year: quarter.year,
      ts_quarter: quarter.quarter_code,
      course_branch: self.branch_code,
      course_no: self.crse_num.strip,
      dept_abbrev: self.subj_code.strip,
      section_id: self.section.strip
    )
  end
  
  def course_students
    return [] unless course

    sdb_course = course

    # Default: just return flat list of students for non-cross-listed
    return sdb_course.all_enrollees.to_a.compact unless sdb_course.joint_listed?

    # Cross-listed: pair each student with the source course, need to handle cycles (A → B → C → A).
    # ECFS 200 A crossed list with ECFS 200 B 
    # ECFS 200 B crossed list with ECFS 200 C 
    # ECFS 200 C crossed list with ECFS 200 A

    result = []
    seen_students = Set.new # ensures uniqueness by student.id.    
    visited_courses = Set.new # ensures we don’t revisit courses (avoids your A → B → C → A loop).
    queue = [sdb_course]

    while queue.any?
      current_course = queue.shift
      next if visited_courses.include?(current_course.id)

      visited_courses << current_course.id

      # Add students (ensure unique by student.id)
      current_course.all_enrollees.to_a.compact.each do |student|
        next if seen_students.include?(student.id) # or student.uwregid

        seen_students << student.id
        result << [student, current_course]
      end

      # Find cross-listed course and enqueue
      cross_list_course = Course.find_by(
        ts_year: quarter.year,
        ts_quarter: quarter.quarter_code,
        course_branch: branch_code,
        course_no: current_course.with_course_no.to_s.strip,
        dept_abbrev: current_course.with_dept_abbrev.to_s.strip,
        section_id: current_course.with_section_id.to_s.strip
      )

      queue << cross_list_course if cross_list_course.present?
    end

    result
  end


  def givepulse_course_students
    begin
      all_results = []
      limit = 50  # GivePulse mxa num for limit
      offset = 0
      total = nil

      loop do
        response = GivepulseUser.request_api('/courseStudents', { course_id: self.id, limit: limit, offset: offset }, method: :get)
        response_body = JSON.parse(response.body)

        # Set total on first response
        total ||= response_body['total'].to_i
        results = response_body['results']

        break if results.empty?

        all_results.concat(results)

        # Increment offset for next batch
        offset += limit

        # Stop if we've fetched all records
        break if all_results.size >= total
      end

      # Convert results to GivepulseUser instances
      all_results.map { |attrs| GivepulseUser.new(attrs) }

    rescue StandardError => e
      Rails.logger.error("Error fetching course students: #{e.message}")
      []
    end
  end

  def course_droppers
    current_enrolled_student_emails = course_students.pluck(:email).compact.map(&:downcase)

    givepulse_course_students.reject do |user|
      user.email.present? && current_enrolled_student_emails.include?(user.email.downcase)
    end
  end
  
  def self.campus_ids
    Rails.env.production? ? CAMPUS_IDS_BY_ENV[:production] : CAMPUS_IDS_BY_ENV[:sandbox]
  end

  # Use community engaged courses GP group id to define campus code
  def branch_code
    self.class.campus_ids[parent_givepulse_id.to_i]
  end

  def self.parent_givepulse_id_from_course_branch(code)
    code = code.to_i
    campus_ids.key(code) 
  end

  def instructors
    return [] unless course

    course.course_meeting_times
        .flat_map { |mt| mt.course_instructors.map(&:instructor) }
        .compact
        .uniq
  end

  # Sync course instructors to GivePulse, adding instructor to a CCUW memeber.  
  # If the instructor (email) exists, it will update the params in this case. 
  # Then the PM can add instructor when they create a course.
  # We do NOT drop any instructors' memebership.  
  def sync_course_instructors
    instructors.each do |instructor|
      if instructor.email.blank?
        Rails.logger.info("Instructor with ID: #{instructor.id} has a blank email and will be skipped.")
        next
      end

      post_params = {
        user: {
          first_name: instructor.firstname,
          last_name:  instructor.lastname,
          email:      instructor.email,
          group_id:   Rails.env.production? ? '1246545' : '757578'
        }
      }

      begin
        response       = GivepulseCourse.request_api("/users", post_params, method: :post)
        response_body  = JSON.parse(response.body)

        if response.code.to_i == 200 || response_body["updated"] == true
          Rails.logger.info("Successfully synced instructor with ID: #{response_body['user_id']}")
        else
          Rails.logger.error("Failed to sync instructor #{instructor.email}. Response code: #{response.code}, Response body: #{response.body}")
        end

      rescue StandardError => e
        Rails.logger.error("Exception occurred while syncing instructor #{instructor.email}: #{e.message}")
      end
    end
  end

  def short_title
    (crn + " " + term) rescue nil
  end

  # We can run this in console or setup a rails task to add quarter's E coruses (take away cross-listed course for now to simplyize)
  # e.g. to add Bothell campus E courses for AUT 2026: b_courses = Quarter.find(414).service_courses.select{|sc|sc.course_branch==1 && sc.joint_listed_with.blank? }
  # b_courses.each{|c| GivepulseCourse.add_course(c) }
  # Add course to GivePulse by SDB course object

  ### E.g. This is the list from Seattle campus, created manually ###
  # seattle_e_designated_courses = [
  #   "D HYG 595 A", "ENGL 471 A", "ENGL 491 B", "FISH 498 A",
  #   "GEN ST 170 A", "GEOG 331 A", "L ARCH 404 A", "L ARCH 499 A",
  #   "NCLIN 418 A", "NCLIN 418 AD", "NCLIN 418 AE", "NCLIN 418 AF",
  #   "NCLIN 418 AG", "NCLIN 418 AH", "NCLIN 418 AI", "NCLIN 418 AJ",
  #   "TRAIN 202 E" ]
  # ce_courses = Quarter.find(414).service_courses.select { |sc| sc.course_branch == 0 && seattle_e_designated_courses.include?(sc.short_title)}

  def self.add_course(course, parent_givepulse_id = nil)

    parent_givepulse_id ||= self.class.parent_givepulse_id_from_course_branch(course.course_branch)

    post_params = {
      term: course.quarter.title,
      crn: course.short_title,
      crse_title: [course.short_title, course.course_title_long, course.quarter.title].join(" "),
      crse_num: course.course_no,
      subj_code: course.dept_abbrev.strip,
      crse_desc: course.course_description,
      parent_givepulse_id: parent_givepulse_id,
      section: course.section_id.strip,
      crse_dept_desc: course.department.name,
      crse_coll_desc: course.course_college,
      class_time: course.class_time,
      class_type: course.class_type
    }

    begin
      response = self.class.request_api('/course', post_params, method: :post)
      body = response.body.to_s
      response_body = JSON.parse(body) rescue {}

      # Rails.logger.debug("GivePulse response class=#{response.class} code=#{response.code} body=#{body}")

      if response.code.to_i == 200 || response_body['total'].to_i > 0
        group_id = response_body.dig('results', 'group_id') || response_body['group_id']
        Rails.logger.info("Successfully created course#{group_id ? " ID: #{group_id}" : ""}")
        true
      else
        Rails.logger.error("Failed to add course. Response code: #{response.code}, Response body: #{body}")
        false
      end
    rescue StandardError => e
      Rails.logger.error("Exception occurred while creating course: #{e.class}: #{e.message}")
    end
  end

  # Updates this GivePulse course using PUT /course/:id.
  # Example: givepulse_course.update(crse_title: "Machine Learning")
  def update(attributes)
    unless id.present?
      Rails.logger.error("Cannot update GivePulse course without a course ID.")
      return false
    end

    response = self.class.request_api("/course/#{id}", attributes, method: :put)
    body = response.body.to_s
    response_body = JSON.parse(body)

    if response['updated']==1 || (response.code.to_i == 200 && response_body["error"].to_i.zero?)
      attributes.each do |key, value|
        public_send("#{key}=", value) if respond_to?("#{key}=")
      end
      Rails.logger.info("Successfully updated GivePulse course #{id}.")
      true
    else
      Rails.logger.error("Failed to update GivePulse course #{id}. Code: #{response.code}, Body: #{body}")
      false
    end
  rescue JSON::ParserError => e
    Rails.logger.error("Invalid JSON returned while updating GivePulse course #{id}: #{e.message}")
    false
  rescue StandardError => e
    Rails.logger.error("Exception occurred while updating GivePulse course #{id}: #{e.class}: #{e.message}")
    false
  end

  # Deletes this GivePulse course using DELETE /course.
  # GivePulse requires both the course ID and delete: "yes" to confirm deletion.
  # Example: givepulse_course.delete
  def delete
    unless id.present?
      Rails.logger.error("Cannot delete GivePulse course without a course ID.")
      return false
    end

    response = self.class.request_api("/course", { id: id, delete: "yes" }, method: :delete)
    body = response.body.to_s
    response_body = JSON.parse(body)

    if response.code.to_i == 200 && response_body["error"].to_i.zero?
      Rails.logger.info("Successfully deleted GivePulse course #{id}.")
      true
    else
      Rails.logger.error("Failed to delete GivePulse course #{id}. Code: #{response.code}, Body: #{body}")
      false
    end
  rescue JSON::ParserError => e
    Rails.logger.error("Invalid JSON returned while deleting GivePulse course #{id}: #{e.message}")
    false
  rescue StandardError => e
    Rails.logger.error("Exception occurred while deleting GivePulse course #{id}: #{e.class}: #{e.message}")
    false
  end


end