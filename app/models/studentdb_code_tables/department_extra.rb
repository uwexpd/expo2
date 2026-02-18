# Stores some extra information about departments that isn't available in the SDB, such as chair name and emails, and department names that are suitable for printing.
class DepartmentExtra < ApplicationRecord
  
  belongs_to :department, foreign_key: :dept_code, optional: true

  has_many :accountability_coordinator_authorizations,
           -> { joins(user_unit_role: :role).where(roles: { name: 'accountability_department_coordinator' }) },
           class_name: 'UserUnitRoleAuthorization',
           as: :authorizable

  PLACEHOLDER_CODES = %w[name chair_name chair_email chair_title].freeze

  delegate :abbrev, :college, to: :department
  
  def email
    chair_email
  end 
  
  def fullname
    chair_name
  end
  
  def name
    department.nil? ? fixed_name : (fixed_name.blank? ? department.name : fixed_name)
  end
  
end
