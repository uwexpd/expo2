class Scholarship < ScholarshipBase
  self.table_name = "scholarships"  
  
  has_many :categories, :class_name => "ScholarshipCategory", :foreign_key => "scholarship_id"
  has_many :disabilities, :class_name => "ScholarshipDisability", :foreign_key => "scholarship_id"
  has_many :ethnicities, :class_name => "ScholarshipEthnicity", :foreign_key => "scholarship_id"
  has_many :types, :class_name => "OmsfaScholarshipType", :foreign_key => "scholarship_id"
  has_many :scholarship_deadlines
  
  accepts_nested_attributes_for :scholarship_deadlines, :categories, :disabilities, :ethnicities, :types, allow_destroy: true
  
  scope :active, -> { where(is_active: true) }
  scope :incoming, -> { where(is_incoming_student: true) }
  scope :upcoming, -> { joins(:scholarship_deadlines).where('scholarship_deadlines.is_active = ? and scholarship_deadlines.deadline >= NOW() and scholarship_deadlines.deadline < DATE_ADD(NOW(), INTERVAL 1 MONTH)', true).uniq }
  
  validates :title, presence: true
  
  def scholarship_type_name
    scholarship_type.collect{|t|t.type.title}
  end

  def class_standings(separator = nil)
     class_standings = []      
     class_standings << "freshman"  if freshman  == 1
     class_standings << "sophomore" if sophomore == 1
     class_standings << "junior"    if junior    == 1
     class_standings << "senior"    if senior    == 1
     class_standings << "graduate"  if graduate  == 1
     class_standings = class_standings.join(separator) if separator
     class_standings
  end
  
  def citizen_types(separator = nil)
    citizen_types = []
    citizen_types << "Us Citizen" if us_citizen == 1
    citizen_types << "Permanent Resident" if permanent_resident == 1
    citizen_types << "International or Other Visa Status" if other_visa_status == 1
    citizen_types << "Undocumented" if hb_1079 == 1
    citizen_types = citizen_types.join(separator) if separator
    citizen_types    
  end
  
  def deadlines(separator = ", ")
    scholarship_deadlines.collect{|d| d.deadline.to_s }.join(separator)
  end
  
end