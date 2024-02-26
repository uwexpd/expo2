# CourseMeetingTime: https://metadata.uw.edu/catalog/viewitem/Table/uwsdbdatastore.timeschedmeetingtimes
# This table indicates the building of the location in which the given meeting of the given section meets. 
# Get Instructor of Record via CourseMeetingTime: https://metadata.uw.edu/catalog/viewitem/Term/b9ee44fc-f86c-42cd-9169-bcd6c674dc59

class CourseMeetingTime < StudentInfo
  self.table_name = "time_sched_meeting_times"
  self.primary_keys = :ts_year, :ts_quarter, :course_branch, :course_no, :dept_abbrev, :section_id  
  belongs_to :course
  
  has_many :course_instructors, -> (course_meeting_time) { 
    where('fac_yr=? AND fac_qtr=? AND fac_branch=? AND fac_curric_abbr=? AND fac_course_no=? AND fac_sect_id=? AND fac_meet_no=?', 
          course_meeting_time.ts_year, course_meeting_time.ts_quarter, course_meeting_time.course_branch, course_meeting_time.dept_abbrev, course_meeting_time.course_no, course_meeting_time.section_id, course_meeting_time.index1)
  }, foreign_key: [:fac_yr, :fac_qtr, :fac_branch, :fac_course_no, :fac_curric_abbr, :fac_sect_id]
  
end