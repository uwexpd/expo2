class Scholarship < ScholarshipRecord
  self.table_name = "scholarships" 
  self.per_page = 20
  
  has_many :categories, :class_name => "ScholarshipCategory", :foreign_key => "scholarship_id"
  has_many :disabilities, :class_name => "ScholarshipDisability", :foreign_key => "scholarship_id"
  has_many :ethnicities, :class_name => "ScholarshipEthnicity", :foreign_key => "scholarship_id"
  has_many :types, :class_name => "OmsfaScholarshipType", :foreign_key => "scholarship_id"
  has_many :scholarship_deadlines
  has_many :scholarship_monthly_deadlines
  
  accepts_nested_attributes_for :scholarship_deadlines, :scholarship_monthly_deadlines, :categories, :disabilities, :ethnicities, :types, allow_destroy: true
  
  scope :active, -> { where(is_active: true) }
  scope :incoming, -> { where(is_incoming_student: true) }
  scope :upcoming, -> { joins(:scholarship_deadlines).where('scholarship_deadlines.is_active = ? and scholarship_deadlines.deadline >= NOW() and scholarship_deadlines.deadline < DATE_ADD(NOW(), INTERVAL 1 MONTH)', true).distinct }
  
  validates :title, presence: true
  
  STANDINGS = [
    [:freshman,   "1st Year"],
    [:sophomore,  "2nd Year"],
    [:junior,     "3rd Year"],
    [:senior,     "4th Year"],
    [:fifth_year, "5th Year"],
    [:graduate,   "Graduate"]
  ].freeze

  CITIZEN_TYPES = [
    [:us_citizen,          "US Citizen"],
    [:permanent_resident,  "Permanent Resident"],
    [:other_visa_status,   "International or Other Visa Status"],
    [:hb_1079,             "Undocumented"]
  ].freeze

  def scholarship_type_name
    scholarship_type.collect{|t|t.type.title}
  end

  def class_standings(separator = nil)
    standings = STANDINGS.select { |field, _| [1, true].include?(send(field)) }.map(&:last)
    separator ? standings.join(separator) : standings
  end
  
  def citizen_types(separator = nil)
    types = CITIZEN_TYPES.select { |field, _| send(field) == 1 }.map(&:last)
    separator ? types.join(separator) : types
  end
  
  def deadlines(separator = ", ")
    scholarship_deadlines.collect{|d| d.deadline.to_s }.join(separator)
  end
  
end