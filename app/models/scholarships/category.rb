class Category < ScholarshipRecord
  self.table_name = "categories"
  
  has_many :scholarship_category
  
  validates_presence_of :name
  
  default_scope { order('name') }
  
  # Alias for #name
  def title
    name
  end
  
  def sub_categories
    Category.where(parent_id: self.id)
  end
end