class ScholarshipCategory < ScholarshipRecord
  self.table_name = "scholarship_categories"
  
  belongs_to :scholarship
  belongs_to :category
  validates :category_id, :scholarship_id, presence: true
  
  def name
    category.name
  end
  
end