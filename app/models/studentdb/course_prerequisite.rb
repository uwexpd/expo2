#https://metadata.uw.edu/catalog/viewitem/Table/uwsdbdatastore.srcourseprereq

class CoursePrerequisite < StudentInfo
  self.table_name = "sr_course_prereq"
  self.primary_keys = :course_branch, :department_abbrev, :course_number  

  def title
    department_abbrev.strip + " " + course_number.to_s
  end

  def prereq_course
    pr_curric_abbr.strip + " " + pr_course_no.to_s
  end
end