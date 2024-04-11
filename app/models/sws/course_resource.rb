class CourseResource < WebServiceResult

  SWS_VERSION = "v5"

  self.element_path = "student/#{SWS_VERSION}/course"

  # https://ws.admin.washington.edu/student/v5/course/2025,SPRING,T%20EDLD,802.json
  def self.find_by_course(year, quarter, dept_abbrev, course_no)
  	dept_abbrev = URI::DEFAULT_PARSER.escape(dept_abbrev) # replace space with '%20'
  	path = "#{self.element_path}/#{year},#{quarter},#{dept_abbrev},#{course_no}.json"
    # puts "Debug path => #{path.inspect}"
	  begin 
      result = self.encapsulate_data(connection.get(path))
      # puts "Debug result => #{result.empty?}"
      return result.empty? ? nil : result
    rescue => e
      puts "An error occurred when getting sws course info: #{e.message}"
      nil
    end	  
  end
  
end