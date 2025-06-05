class GivepulseCourse < GivepulseBase
  include ActiveModel::Model

  # Attributes for the User
  attr_accessor :id, :crn, :term, :group_id, :subj_code, :crse_num, :crse_title, 
              :crse_desc, :parent_givepulse_id, :section, :cross_list_code, 
              :dept_code, :crse_dept_desc, :crse_coll_code, :crse_coll_desc, 
              :class_time, :class_type, :class_status, :sl_type, 
              :givepulse_organizer_id, :faculty_id, :faculty2_id, :faculty3_id

  # Example Use: GivepulseCourse.find_by(term: 'SUM2025' , crn: 'BHS496A')
  # GivepulseCourse.where(group_id: 788279)
  def self.where(attributes)
  	begin

	   response = request_api('/courses', attributes, method: :get)     
     response = JSON.parse(response.body)     

  	 if response['total'].to_i > 0
        results = response['results']
        courses = results.map { |attrs| GivepulseCourse.new(attrs) }
        # Rails.logger.debug("***** DEBUG courses => #{courses.inspect}")
        return courses.first if courses.size == 1
        courses
  	 else
  	 	 Rails.logger.warn("No courses found with attributes: #{attributes}")
  	   nil
  	 end
	rescue StandardError => e
      Rails.logger.error("Error fetching courses: #{e.message}")
      nil
    end
  end

  # Alias `where` to `find_by`
  def self.find_by(attributes)
    where(attributes)
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

  # Add course students to GivePulse
  # If the student (email) exists, it will update the params in this case. [Tested]
  # [TODO] handle course droppers and mismatch. 
  def add_students
    # Student.find(529893, 340224).each do |student| # For test
  	self.course_students.each do |student|
      
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
         is_private: 1
        }
  	  }
  	  # Rails.logger.debug("Debug post_params => #{post_params}")
  	  begin
  	  	# response = make_post_request('/users', post_params, { 'Content-Type' => 'application/json' })
        response = GivepulseCourse.request_api("/users", post_params, method: :post)
  	  	response_body = JSON.parse(response.body)
  	  	# Rails.logger.debug("Add Students Debug response=> #{response}")
    		if response.code.to_i == 200 || response_body["updated"] == true
    			Rails.logger.info("Successfully added student with ID: #{response_body['user_id']}")
    		else
    			Rails.logger.error("Failed to add student #{student.email}. Response code: #{response.code}, Response body: #{response.body}")
    		end
  	  rescue StandardError => e
  	    Rails.logger.error("Exception occurred while adding student #{student.email}: #{e.message}")
  	  end
	  end
  end

  def quarter
  	Quarter.find_by_abbrev(self.term)
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
  	course.all_enrollees.flatten
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