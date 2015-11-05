class Person < ActiveRecord::Base
  
  has_many :users
  
  # validates_presence_of :salutation, :if => :require_validations?
  validates_presence_of :firstname, :if => :require_validations?
  validates_presence_of :firstname, :if => :require_name_validations?
  validates_presence_of :lastname, :if => :require_validations?
  validates_presence_of :lastname, :if => :require_name_validations?
  validates_presence_of :email, :if => :require_validations?
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :if => :require_validations?
  validates_presence_of :address1, :if => :require_address_validations?
  validates_presence_of :city, :if => :require_address_validations?
  validates_presence_of :state, :if => :require_address_validations?
  validates_presence_of :zip, :if => :require_address_validations?
  validate :student_validations, :if => :require_student_validations?
#  validates_inclusion_of :gender, :in => ['M','F',nil]

  named_scope :non_student, :conditions => { :type => nil }

  attr_accessor :require_validations, :require_name_validations, :require_address_validations, :require_student_validations
  
  def require_validations?
    require_validations
  end
  
  def require_name_validations?
    return false if self.is_a?(Student)
    require_name_validations
  end
  
  def require_address_validations?
    return false if self.is_a?(Student)
    require_address_validations
  end
  
  def require_student_validations?
    return false if self.is_a?(Student)
    require_student_validations
  end
  
  def student_validations
    unless self.is_a?(Student)
      errors.add :major_1, "can't be blank" if major_1.blank?
      errors.add :institution_id, "can't be blank" if institution_id.nil?
      errors.add :class_standing_id, "can't be blank" if class_standing_id.nil?
    end
  end    
  
end