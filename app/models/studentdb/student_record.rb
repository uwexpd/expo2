class StudentRecord < StudentInfo
  self.table_name = "student_1_v"
  self.primary_key = "system_key"
  has_one :student_person, :class_name => "Student", :foreign_key => "system_key"
  has_one :record2, :class_name => "StudentRecord2", :foreign_key => "system_key"
  has_one :address, :class_name => "StudentAddress", :foreign_key => "system_key"
  has_many :transcripts, :class_name => "StudentTranscript", :foreign_key => "system_key"
  has_many :admission_applications, :class_name => "StudentAdmissionApplication", :foreign_key => "system_key"
  has_many :transfers, :class_name => "StudentTransfer", :foreign_key => "system_key"
  has_many :majors, :class_name => "StudentMajor", :foreign_key => "system_key"
  has_many :minors, :class_name => "StudentMinor", :foreign_key => "system_key"
  belongs_to :class_standing_record, :class_name => "ClassStanding", :foreign_key => "class"  
  belongs_to :class_standing_record, :class_name => "ClassStanding", :foreign_key => "class"
  belongs_to :ethnic_ethnicity, :class_name => "Ethnicity", :foreign_key => "ethnic_code"
  belongs_to :hispanic_ethnicity, :class_name => "Ethnicity", :foreign_key => "hispanic_code"
  belongs_to :special_program, :class_name => "SpecialProgram", :foreign_key => "spcl_program"
  belongs_to :high_school, :class_name => "HighSchool", :foreign_key => "high_sch_ceeb_cd"
  belongs_to :last_institution, :class_name => "Institution", :foreign_key => "last_sch_code"
  
  PLACEHOLDER_CODES = %w(fullname formal_fullname firstname lastname his_her him_her he_she email salutation formal_greeting
                          class_standing_description majors_list minors_list institution_name last_institution_name transfer_student?
                          student_no student_no_pretty system_key gpa age birth_date gender)
  PLACEHOLDER_ASSOCIATIONS = %w(special_program ethnicity)

  # Returns the Student object that is associated with this StudentRecord. If a Student object does not exist for this student yet, it
  # will automatically be created unless +false+ is passed as the only variable.
  def student(create_person = true)
    return student_person if student_person
    if create_person
       s = Student.find_or_create_by_system_key(system_key)
     else
       nil
     end
  end

  alias :person :student

  def sws
    @sws ||= StudentResource.find_by_system_key(system_key, true)
  end

  # Fetches the regID for this student from the SWS
  def reg_id
    @reg_id ||= StudentResource.find_by_system_key(system_key, false)
  end
  
  # Returns true if we are successfully able to find a matching student record for the given UW NetID. It's still possible that
  # the NetID in question could exist, but it doesn't belong to a student with a student record.
  def self.valid_uw_netid?(netid)
    !find(:first, :conditions => { :uw_netid => netid }).nil?
  end
  
  def fullname
    student_name_lowc.strip.gsub(',', ', ')
  end

  def lastname
    fullname.split(',')[0]
  end
  
  def firstname
    fullname.split(',')[1].split(' ')[0]
  end
  
  def title
    fullname
  end
  
  def student_no_pretty
    read_attribute('student_no').to_s.rjust(7,'0')
  end
  
  def last_institution_name
    last_institution.try(:name)
  end
  
  def high_school_name
    high_school.try(:name)
  end

  def gender
    s1_gender
  end
  
  def email
    return "" if uw_netid.blank?
    address.e_mail_ucs.blank? ? "#{uw_netid.strip}@u.washington.edu" : address.e_mail_ucs.strip rescue "#{uw_netid.strip}@u.washington.edu"
  end

  # Returns the student's GPA as a string of a number to 2 decimal places, e.g., "3.34". Any problems return "unknown".
  def gpa
    '%.2f' % raw_gpa rescue "unknown"
  end
  
  # Returns the student's GPA as a Float value. Any problems return +NaN+.
  def raw_gpa
    tot_grade_points/tot_graded_attmp rescue 0.0/0.0
  end
  
  def age
    # ((Date.today - birth_date.to_date).to_f/365.25).floor
    age = Date.today.year - birth_date.to_date.year
    age -= 1 if Date.today < birth_date.to_date + age.years #for days before birthday
    return age
  end

  # Returns this student's date of birth. In the SDB, birth date is stored both in a timestamp field (+birth_dt+) and in 3 smallint fields
  # (+yr_of_birth+, +mth_of_birth+, and +day_of_birth+). Sometimes, the birth_dt field is nil or "0000-00-00 00:00:00", in which case this
  # method constructs a valid birth date from these three fields. Otherwise, return +birth_dt+.
  def birth_date
    year = yr_of_birth > 30 ? yr_of_birth+1900 : yr_of_birth+2000
    birth_dt.nil? ? Date.new(year, mth_of_birth, day_of_birth) : birth_dt.to_date
  end
  
  # Returns a list of the student's majors. By default, this is a comma-separated list of the major abbreviations, but this can
  # be changed by passing parameters to include your own join string and/or include full major names. Does not include
  # the "Non Matriculated" major name.
  # 
  # To see this student's majors list from a previous quarter, specify that quarter for +reference_quarter+. If the student had no
  # majors in that quarter, this method returns a blank string.
  def majors_list(show_full_names = true, join_string = ", ", reference_quarter = nil)
    if reference_quarter.nil? || (Quarter.current_quarter == reference_quarter)      
      ref_majors = majors
    else
      t = transcripts.find([system_key, reference_quarter.year, reference_quarter.quarter_code_id]) rescue nil
      t = (transcripts.find([system_key, reference_quarter.prev.year, reference_quarter.prev.quarter_code_id]) rescue nil) if t.nil?
      ref_majors = t.nil? ? [] : t.majors
    end
    ref_majors.collect { |m| show_full_names ? m.full_name : m.major_abbr.strip }.reject{|m| m == "Non Matriculated" }.join(join_string)
  end

  # Returns a list of the student's minors. By default, this is a comma-separated list of the minor abbreviations, but this can
  # be changed by passing parameters to include your own join string and/or include full minor names.
  # CURRENTLY, this will always only show abbreviations because titles aren't in the student database.
  def minors_list(show_full_names = false, join_string = ", ")
    minors.collect { |m| m.minor_abbr.strip }.join(join_string)
  end
  
  
end