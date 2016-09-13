class Disability < ScholarshipBase
  self.table_name = "disabilities"
  
  has_many :scholarship_disability
  
  validates_presence_of :name
  
  # Alias for #name
  def title
    name
  end
  
end