class ScholarshipMonthlyDeadline < ScholarshipRecord
  self.table_name = "scholarship_monthly_deadlines"
  
  belongs_to :scholarship
  validates :scholarship_id, :deadline_month, presence: true
  
end