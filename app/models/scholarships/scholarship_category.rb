class ScholarshipCategory < ScholarshipBase
  self.table_name = "scholarship_categories"
  
  belongs_to :scholarship
  belongs_to :category
  
  def name
    category.name
  end
  
end