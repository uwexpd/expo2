class Type < ScholarshipRecord
  self.table_name = "types"
  
  has_many :omsfa_scholarship_type
  
  validates_presence_of :name
  
  default_scope { order('name') }
  
  # Alias for #name
  def title
    name
  end
  
end