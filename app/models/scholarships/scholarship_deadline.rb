class ScholarshipDeadline < ScholarshipBase
  self.table_name = "scholarship_deadlines"
  
  belongs_to :scholarship
  belongs_to :category
  
end