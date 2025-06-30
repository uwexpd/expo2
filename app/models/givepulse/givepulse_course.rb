class GivepulseCourse < GivepulseBase
  include ActiveModel::Model

  # Attributes for the User
  attr_accessor :id, :crn, :term, :group_id, :subj_code, :crse_num, :crse_title, 
              :crse_desc, :parent_givepulse_id, :section, :cross_list_code, 
              :dept_code, :crse_dept_desc, :crse_coll_code, :crse_coll_desc, 
              :class_time, :class_type, :class_status, :sl_type, 
              :givepulse_organizer_id, :faculty_id, :faculty2_id, :faculty3_id

  # Example Use: GivepulseCourse.where(term: 'SUM2025' , crn: 'BHS496A')
  # GivepulseCourse.where(group_id: 788279)
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
  	   nil
  	 end
	  rescue StandardError => e
      Rails.logger.error("Error fetching courses: #{e.message}")
      nil
    end
  end

  # Add course to GivePulse by SDB course object
  def self.add_course(course, parent_givepulse_id = nil, crse_desc = nil)
  	
  	post_params = {
  		term: course.quarter.abbrev,
  		crn: course.abbrev,
  		crse_num: course.course_no,
  		crse_title: course.dept_abbrev, 
  		crse_desc: crse_desc,
  		parent_givepulse_id: parent_givepulse_id,
  		section: course.section_id.strip
  	}

  	begin
  	  	response = make_post_request('/course', post_params, { 'Content-Type' => 'application/json' })
  	  	response_body = JSON.parse(response.body)
  	  	Rails.logger.debug("Debug response=> #{response}")

		if response.code.to_i == 200 || response_body['total'].to_i > 0
			Rails.logger.info("Successfully created course ID: #{response_body['results']['gorup_id']}")
		else
			Rails.logger.error("Failed to add course. Response code: #{response.code}, Response body: #{response_body}")
		end
	rescue StandardError => e
	    Rails.logger.error("Exception occurred while creating course: #{e.message}")
	end

  end

  # Sync course students to GivePulse
  # If the student (email) exists, it will update the params in this case. [Tested]
  # Handle course droppers and mismatch. 
  def sync_course_students
    # Normalize for roster email comparison
    sdb_emails = self.course_students.to_a.map { |s| s.email&.downcase }.compact
    givepulse_students = self.givepulse_course_students || []
    givepulse_emails = givepulse_students.map { |u| u.email&.downcase }.compact
    
    # 1. Sync current students
  	self.course_students.each do |student|
      
      email = student.email&.downcase
      next unless email

      admin_minor = student.sdb.age < 18 ? "Yes" : "No"
      admin_dir_release = student.dir_release ? "Yes" : "No"
      admin_fields = if Rails.env.production?
        { "236072" => admin_minor, "236073" => admin_dir_release }
      else
        { "81445" => admin_minor, "81773" => admin_dir_release }
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
    # droppers = givepulse_students.reject do |gp_user|
    #   sdb_emails.include?(gp_user.email&.downcase)
    # end

    # droppers.each do |dropper|

    #   drop_params = {
    #         email: dropper.email,
    #         course_id: self.id,
    #         delete: "yes" 
    #   }

    #   begin
    #     Rails.logger.info("Removing dropper, #{dropper.email}, from the GivePulse course #{self.crn}")
    #     response = GivepulseCourse.request_api("/courseStudent", drop_params, method: :delete)
    #     #Rails.logger.debug("Debug response DELETE => #{response}")

    #     if response.code.to_i == 200
    #       Rails.logger.info("Successfully removed #{dropper.email} from GivePulse course #{self.crn}")
    #     else
    #       Rails.logger.error("Failed to remove #{dropper.email}. Code: #{response.code}, Body: #{response.body}")
    #     end
    #   rescue StandardError => e
    #     Rails.logger.error("Exception removing #{dropper.email}: #{e.message}")
    #   end
    # end
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
      dept_abbrev: self.crse_title,
      section_id: self.section
    )
  end
  
  def course_students
     return [] unless course
     sdb_course = course
     qtr = quarter
     all_courses = [sdb_course]
     
     if sdb_course.joint_listed?
        cross_list_course = Course.find_by(
          ts_year: qtr.year,
          ts_quarter: qtr.quarter_code,
          course_branch: self.branch_code,
          course_no: sdb_course.with_course_no.to_s.strip,
          dept_abbrev: sdb_course.with_dept_abbrev.to_s.strip,
          section_id: sdb_course.with_section_id.to_s.strip
        )
        all_courses << cross_list_course if cross_list_course.present?
     end 

  	  all_courses.map(&:all_enrollees).compact.flatten
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
  

end