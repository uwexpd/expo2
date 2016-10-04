class ScholarshipDeadline < ScholarshipBase
  self.table_name = "scholarship_deadlines"
  
  belongs_to :scholarship
  validates :scholarship_id, :deadline, presence: true
  
end