# Models a individual student project that should be counted in an accountability report. See AccountabilityReport for more information.
class ActivityProject < Activity
  validates :system_key, presence: true

  # Associations
  belongs_to :student, class_name: 'StudentRecord', foreign_key: 'system_key', optional: true

  # Scopes
  # Returns records with quarters matching the requested quarter(s)
  scope :for_quarters, ->(q) {
    quarter_ids = q.is_a?(Array) ? q.map(&:id) : q.id
    joins(:quarters).select('DISTINCT activities.*').where('activity_quarters.quarter_id IN (?)', quarter_ids)
  }

  # Returns records assigned to the specified department
  scope :for_department, ->(d) {
    case d
    when DepartmentExtra
      if d.dept_code.present?
        where(department_id: d.dept_code)
      elsif d.fixed_name.blank?
        where(department_id: 99999999) # return no results
      else
        where(department_name: d.fixed_name)
      end
    when Department
      where(department_id: d.id)
    when String
      where(department_name: d)
    else
      none # returns an empty ActiveRecord::Relation if none of the above
    end
  }

  private

  def self.correct_dept_id(obj)
    obj.is_a?(DepartmentExtra) ? obj.dept_code : obj.id
  end
end