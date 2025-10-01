# Models a individual student project that should be counted in an accountability report. See AccountabilityReport for more information.
class ActivityProject < Activity
  validates_presence_of :system_key
  
  belongs_to :student, :class_name => "StudentRecord", :foreign_key => "system_key"

  # Only return records with quarters that match the requested quarter
  # scope :for_quarter, -> (quarter) { joins(:quarters).where("activity_quarters.quarter_id IN (#{quarter.is_a?(Array) ? quarter.collect(&:id).join(",") : quarter.id})").uniq }
  scope :for_quarters, ->(q) {
    joins(:quarters)
    .select("DISTINCT activities.*")
    .where("activity_quarters.quarter_id IN (?)", q.is_a?(Array) ? q.pluck(:id) : q.id)
  }
  
  # Only return records assigned to this department
  scope :for_department, -> (d) {
    if d.is_a?(DepartmentExtra)
      if !d.dept_code.blank?
        where(:department_id => d.dept_code)
      elsif d.fixed_name.blank?
        where(:department_id => 99999999) # return nothing
      else
        where(:department_name => d.fixed_name )
      end
    elsif d.is_a?(Department)
      where(:department_id => d.id )
    elsif d.is_a?(String)
      where(:department_name => d )
    end
  }

  private

  def self.correct_dept_id(obj)
    obj.is_a?(DepartmentExtra) ? obj.dept_code : obj.id
  end
  
end