# Add 'Omsfa' prefix for the class name to avoid same class name with SDB Ethnicity
class OmsfaEthnicity < ScholarshipRecord
  self.table_name = "ethnicities"
  
  has_many :scholarship_ethnicity
  
  validates_presence_of :name
  
  default_scope { order('name') }
  
  # Alias for #name
  def title
    name
  end
  
end