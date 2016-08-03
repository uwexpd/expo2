class StudentRecord < StudentInfo
  self.table_name = "student_1_v"
  self.primary_key = "system_key"
  has_one :student_person, :class_name => "Student", :foreign_key => "system_key"
  
  
end