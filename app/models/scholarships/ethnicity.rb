class Ethnicity < ScholarshipBase
  self.table_name = "ethnicities"
  
  has_many :scholarship_ethnicity
  
  validates_presence_of :name
  
  default_scope { order('name') }
  
  # Alias for #name
  def title
    name
  end
  
end