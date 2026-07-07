#https://metadata.uw.edu/catalog/viewitem/Table/uwsdbdatastore.timeschedmeetingtimes
# This table indicates the building of the location in which the given meeting of the given section meets. 
# Use this relationship to find the instructor information with 
class CourseInstructor  < StudentInfo
  self.table_name = "sec.sr_course_instr"
  self.primary_keys = :fac_yr, :fac_qtr, :fac_branch, :fac_course_no, :fac_curric_abbr, :fac_sect_id
  
  belongs_to :instructor, foreign_key: :fac_ssn
  belongs_to :course_meeting_time, foreign_key: [:fac_yr, :fac_qtr, :fac_branch, :fac_course_no, :fac_curric_abbr, :fac_sect_id]
end