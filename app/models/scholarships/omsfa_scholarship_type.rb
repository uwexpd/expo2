# Add 'Omsfa' prefix for the class name to avoid same class name with SDB ScholarshipType
class OmsfaScholarshipType < ScholarshipBase
  self.table_name = "scholarship_types"
  
  belongs_to :scholarship
  belongs_to :type
  validates :scholarship_id, :type_id, presence: true
  
end