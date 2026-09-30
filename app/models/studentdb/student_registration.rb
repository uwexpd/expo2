# Registration is the prospective view of the interaction between the student and the University of Washington's course offerings. Registration is the entity of record until Grade Posting/Transcript Generation (process JSR405), at which time the entity of record becomes the transcript (a retrospective view). Note that this implies that the validity of data in Registration ends at this time. Registration is current and future quarter student enrollment information and student program information. For information on prior quarters, refer instead to the transcript tables.
class StudentRegistration < StudentInfo
  self.table_name = "sec.registration"
  self.primary_keys = :system_key, :regis_yr, :regis_qtr
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  has_many :courses, :class_name => "StudentRegistrationCourse", :foreign_key => ["system_key", "regis_yr", "regis_qtr"] do
    def enrolled
      find(:all, :conditions => "request_status IN ('A','C','R')")
    end
    def fetch_course_credits(course)
      find(:first, :conditions => ['course_branch = ? and crs_number = ? and crs_curric_abbr = ? and crs_section_id = ?', course.course_branch, course.course_no, course.dept_abbrev.strip, course.section_id.strip]).credits.to_i
    end
  end

  REGISTERED_ENROLLMENT_STATUS = 12
  CAMPUS_BRANCHES = [0, 1, 2].freeze

  # Registrations in the academic quarter assigned by dimDate to the supplied date.
  scope :in_academic_quarter_on, lambda { |date|
    where(<<~SQL.squish, date)
      sec.registration.regis_yr * 10 + sec.registration.regis_qtr = (
        SELECT d.AcademicContigYrQtrCode
        FROM EDWPresentation.sec.dimDate AS d
        WHERE d.CalendarDate = CONVERT(date, ?)
      )
    SQL
  }

  # Retained for callers that need today's academic quarter.
  scope :in_current_academic_quarter, -> { in_academic_quarter_on(Date.current) }

  scope :registered, -> {
    where("sec.registration.enroll_status = ?", REGISTERED_ENROLLMENT_STATUS)
  }

  # campus: 0 = Seattle, 1 = Bothell, 2 = Tacoma, :all or "ALL" = all campuses.
  # date: a Date/Time or an "MM-DD-YYYY" string; defaults to today.
  # Returns StudentRegistration records, one per qualifying registration.
  def self.current_enrolled(campus = :all, date = Date.current)
    campus = normalize_campus_branch(campus)
    date = normalize_enrollment_date(date)

    relation = joins(<<~SQL.squish)
      INNER JOIN sec.student_1 AS student
        ON student.system_key = sec.registration.system_key
      INNER JOIN sec.student_1_college_major AS major
        ON major.system_key = student.system_key
       AND major.index1 = 1
    SQL
      .in_academic_quarter_on(date)
      .registered
      .where("student.student_no > 0")
      .where("student.test_student = 0")
      .where("ISNULL(student.deceased_dt, 0) <= 0")

    campus == :all ? relation : relation.where("major.branch = ?", campus)
  end

  def self.normalize_campus_branch(campus)
    return :all if campus.nil? || campus.to_s.casecmp("all").zero?

    branch = Integer(campus)
    return branch if CAMPUS_BRANCHES.include?(branch)

    raise ArgumentError, "campus must be 0 (Seattle), 1 (Bothell), 2 (Tacoma), or :all"
  rescue ArgumentError, TypeError
    raise ArgumentError, "campus must be 0 (Seattle), 1 (Bothell), 2 (Tacoma), or :all"
  end

  def self.normalize_enrollment_date(date)
    return Date.strptime(date, "%m-%d-%Y") if date.is_a?(String)
    return date.to_date if date.respond_to?(:to_date)

    raise ArgumentError, "date must be a Date/Time or an MM-DD-YYYY string"
  rescue Date::Error
    raise ArgumentError, "date must be an MM-DD-YYYY string, for example 09-30-2026"
  end

  
end
