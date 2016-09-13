class ScholarshipDisability < ScholarshipBase
  self.table_name = "scholarship_disabilities"
  
  belongs_to :scholarship
  belongs_to :disablility
  
end