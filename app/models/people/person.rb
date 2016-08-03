class Person < ActiveRecord::Base
  
  has_many :users
  
  validates :firstname, presence: true, if: [ :require_validations?, :require_name_validations? ]
  validates :lastname,  presence: true, if: [ :require_validations?, :require_name_validations? ]
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i}, if: :require_validations?  
  validates :address1, presence: true, if: :require_address_validations?
  validates :city, presence: true, if: :require_address_validations?
  validates :state, presence: true, if: :require_address_validations?
  validates :zip, presence: true, if: :require_address_validations?
  validate :student_validations, :if => :require_student_validations?

  scope :non_student, -> { where(type: nil) }

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