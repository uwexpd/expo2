class ScholarshipType < ScholarshipBase
  self.table_name = "scholarship_types"
  
  belongs_to :scholarship
  belongs_to :type
  
end