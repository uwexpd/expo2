class ScholarshipEthnicity < ScholarshipBase
  self.table_name = "scholarship_ethnicities"
  
  belongs_to :scholarship
  belongs_to :ethnicity
  validates :scholarship_id, :ethnicity_id, presence: true
  
end