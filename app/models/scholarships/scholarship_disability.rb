class ScholarshipDisability < ScholarshipRecord
  self.table_name = "scholarship_disabilities"
  
  belongs_to :scholarship
  belongs_to :disablility
  validates :scholarship_id, :disability_id, presence: true
  
end