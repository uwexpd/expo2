class ScholarshipEthnicity < ScholarshipBase
  self.table_name = "scholarship_ethnicities"
  
  belongs_to :scholarship
  belongs_to :ethnicity
  
end