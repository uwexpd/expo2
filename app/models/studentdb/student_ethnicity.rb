class StudentEthnicity < StudentInfo
  self.table_name = "sec.student_1_ethnic"
  self.primary_key = :system_key
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  belongs_to :ethnic_ethnicity, :class_name => "Ethnicity", :foreign_key => "ethnic"  
  
end
