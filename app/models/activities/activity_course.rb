# Models a course that should be counted in an accountability report. See AccountabilityReport for more information.
# 
# * For ActivityCourse records, a separate "reporting department" can be specified. For example, a BIO course might be
#   reported by the Medical School, in which case, both Biology and the Medical School will receive "credit" when the
#   accountability report is run.
class ActivityCourse < Activity
  # Validations
  validates :ts_year, :ts_quarter, :course_branch, :course_no, :dept_abbrev, :section_id, presence: true
  validates :course, presence: true
  validates_associated :course
  validates :activity_type_id, presence: true

  # Associations
  # Note: Rails 5.2 does not support composite foreign keys natively.
  # You may need to handle this association manually or with a gem like composite_primary_keys.
  # For now, assuming a single foreign key or manual handling.
  # belongs_to :course, class_name: 'Course', foreign_key: 'course_id', optional: false
  belongs_to :course, :class_name => "Course", :foreign_key => [:ts_year, :ts_quarter, :course_branch, :course_no, :dept_abbrev, :section_id]

  belongs_to :reporting_department, class_name: 'Department', foreign_key: 'reporting_department_id', optional: true
  belongs_to :preparer, class_name: 'Unit', foreign_key: 'preparer_uw_netid', primary_key: 'login', optional: true

  delegate :registrants, to: :course

  # Setter for quarter_id that sets ts_year and ts_quarter accordingly
  def quarter_id=(q_id)
    q = Quarter.find(q_id)
    self.ts_year = q.year
    self.ts_quarter = q.quarter_code_id
    super(q.id)
  end

  # Scope equivalent for for_quarter
  def self.for_quarter(quarter)
    if quarter.is_a?(Array)
      where(quarter_id: quarter.map(&:id))
    else
      where(quarter_id: quarter.id)
    end
  end

  # Returns the full reporting department name, if any
  def full_reporting_department_name
    return nil if reporting_department_id.nil? && reporting_department_name.blank?

    reporting_department&.name || reporting_department_name
  end

  # Scope equivalent for for_quarter_and_department
  def self.for_quarter_and_department(quarter, department)
    quarters = quarter.is_a?(Array) ? quarter : [quarter]
    quarter_ids = quarters.map(&:id)

    query = where(quarter_id: quarter_ids)

    case department
    when Department
      query = query.where('department_id = ? OR reporting_department_id = ?', department.id, department.id)
    when DepartmentExtra
      if department.dept_code.present?
        query = query.where('department_id = ? OR reporting_department_id = ?', department.dept_code, department.dept_code)
      else
        query = query.where(reporting_department_name: department.fixed_name)
      end
    when String
      query = query.where(reporting_department_name: department)
    else
      raise ArgumentError, 'You must pass a Department, DepartmentExtra, or a String'
    end

    query
  end

  # Checks if the ActivityCourse belongs to the given department
  def belongs_to_department?(department)
    case department
    when Department
      department_id == department.id || reporting_department_id == department.id
    when DepartmentExtra
      if department.dept_code.present?
        department_id == department.dept_code || reporting_department_id == department.dept_code
      else
        reporting_department_name == department.fixed_name
      end
    when String
      reporting_department_name == department
    else
      raise ArgumentError, 'You must pass a Department, DepartmentExtra, or a String'
    end
  end

  # Checks if the ActivityCourse can be edited by the given department
  def can_be_edited_by?(department)
    if reporting_department_id.nil? && reporting_department_name.blank?
      belongs_to_department?(department)
    else
      case department
      when Department
        reporting_department_id == department.id
      when DepartmentExtra
        if department.dept_code.present?
          reporting_department_id == department.dept_code
        else
          reporting_department_name == department.fixed_name
        end
      when String
        reporting_department_name == department
      else
        raise ArgumentError, 'You must pass a Department, DepartmentExtra, or a String'
      end
    end
  end
end