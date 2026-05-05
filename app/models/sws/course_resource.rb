class CourseResource < WebServiceResult
  SWS_VERSION = "v5"
  self.element_path = "student/#{SWS_VERSION}/course"

  def self.find_by_course(year, quarter, dept_abbrev, course_no)
    dept_abbrev = URI::DEFAULT_PARSER.escape(dept_abbrev)
    path = "#{element_path}/#{year},#{quarter},#{dept_abbrev},#{course_no}.json"

    begin
      data = encapsulate_data(connection.get(path))
      return nil if data.nil? || data.empty?
      new(data)
    rescue => e
      Rails.logger.error("An error occurred when getting sws course info: #{e.message}")
      nil
    end
  end  

  def course_description
    attrs["CourseDescription"]
  end

  def title_long
    attrs["CourseTitleLong"]
  end

  def course_college
    attrs["CourseCollege"]
  end

  def course_campus
    attrs["CourseCampus"]
  end

end