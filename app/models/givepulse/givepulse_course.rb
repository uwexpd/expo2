class GivepulseCourse < GivepulseBase
  include ActiveModel::Model

  # Attributes for the User
  attr_accessor :id, :crn, :term, :group_id, :subj_code, :crse_num, :crse_title, 
              :crse_desc, :parent_givepulse_id, :section, :cross_list_code, 
              :dept_code, :crse_dept_desc, :crse_coll_code, :crse_coll_desc, 
              :class_time, :class_type, :class_status, :sl_type, 
              :givepulse_organizer_id, :faculty_id, :faculty2_id, :faculty3_id

  # Example Use: GivepulseCourse.where(term: 'SUM2025' , crn: 'BHS496A')
  # GivepulseCourse.find_by(group_id: 788279)
  def self.where(attributes)
  	begin
	   response = request_api('/courses', attributes, method: :get)     
     response = JSON.parse(response.body)

  	 if response['total'].to_i > 0
        results = response['results']
        courses = results.map { |attrs| new(attrs.slice(*permitted_attrs)) }
        # Rails.logger.debug("***** DEBUG courses => #{courses.inspect}")
  	 else
  	 	 Rails.logger.warn("No courses found with attributes: #{attributes}")
  	   []
  	 end
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
    sdb_emails = self.course_students.to_a.map do |entry|
      student = entry.is_a?(Array) ? entry.first : entry
      student.email&.downcase
    end.compact
    givepulse_students = self.givepulse_course_students || []
    givepulse_emails = givepulse_students.map { |u| u.email&.downcase }.compact
    
    # 1. Sync current students
    self.course_students.each do |entry|
      if entry.is_a?(Array)
        student, source_course = entry
        course_section = "#{source_course.short_title}"
      else
        student = entry
        course_section = nil
      end

      email = student.email&.downcase
      next unless email

      admin_minor = student.sdb.age < 18 ? "Yes" : "No"
      admin_dir_release = student.dir_release ? "Yes" : "No"
      admin_fields = if Rails.env.production?
        { "236072" => admin_minor, "236073" => admin_dir_release, "239467" => course_section }
      else
        { "81445" => admin_minor, "81773" => admin_dir_release, "82030" => course_section }
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
  	  	# Rails.logger.debug("Sync Students Debug response=> #{response}")
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

    droppers.each do |dropper|

      drop_params = {
            email: dropper.email,
            course_id: self.id,
            delete: "yes"
      }

      begin
        Rails.logger.info("Removing dropper, #{dropper.email}, from the GivePulse course #{self.crn}")

        response = GivepulseCourse.request_api("/courseStudent", drop_params, method: :delete)
        #Rails.logger.debug("Debug response DELETE => #{response}")

        if response.code.to_i == 200
          Rails.logger.info("Successfully removed #{dropper.email} from GivePulse course #{self.crn}")
         
          # Send email notification to the course admins in CCUW         
          GivepulseUser.where(group_id: self.group_id, role: 'admin').each do |course_admin|
            link = Rails.env.production? ? "https://uw.givepulse.com/group/manage/users/#{self.group_id}" : "https://uw-dev.givepulse.com/group/manage/users/#{self.group_id}"

            begin
              mail = CommunityEngagedMailer.templated_message(
                course_admin,
                EmailTemplate.find_by_name("ccuw course dropper notification"),
                course_admin.email,
                link,
                { student_name: "#{dropper.first_name} #{dropper.last_name}", student_email: dropper.email }
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
      course_no: self.crse_num,
      dept_abbrev: self.subj_code,
      section_id: self.section
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
     response = GivepulseUser.request_api('/courseStudents', {course_id: self.id}, method: :get)
     response = JSON.parse(response.body)

     if response['total'].to_i > 0
        results = response['results']
        # Rails.logger.debug("***** DEBUG results => #{results.inspect}")
        results.map { |attrs| GivepulseUser.new(attrs) }        
     else
       Rails.logger.warn("No course students found with the givepulse course: #{self.crn}")
       []
     end
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

  # Use community engaged courses GP group id to define campus code
  def branch_code
    campus_ids =  if Rails.env.production?
                    { 1479590 => 0, 1479577 => 1, 1480803 => 2 }
                  else
                    { 792610 => 0, 792620 => 1, 811201 => 2 }
                  end

    campus_ids[self.parent_givepulse_id]
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
      next if instructor.email.blank?

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

  # Add course to GivePulse by SDB course object
  def self.add_course(course, parent_givepulse_id = nil, crse_desc = nil)
    
    post_params = {
      term: course.quarter.abbrev,
      crn: course.abbrev,
      crse_num: course.course_no,
      subj_code: course.dept_abbrev,
      crse_desc: crse_desc,
      parent_givepulse_id: parent_givepulse_id,
      section: course.section_id.strip
    }

    begin
        response = GivepulseCourse.request_api('/course', post_params, method: :post)
        response_body = JSON.parse(response.body)
        Rails.logger.debug("Debug response=> #{response}")

      if response.code.to_i == 200 || response_body['total'].to_i > 0
        Rails.logger.info("Successfully created course ID: #{response_body['results']['group_id']}")
      else
        Rails.logger.error("Failed to add course. Response code: #{response.code}, Response body: #{response_body}")
      end
    rescue StandardError => e
        Rails.logger.error("Exception occurred while creating course: #{e.message}")
    end
  end


end