class StudentRecord < StudentInfo
  self.table_name = "student_1_v"
  self.primary_key = "system_key"
  has_one :student_person, :class_name => "Student", :foreign_key => "system_key"
  
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
  
  
  
  
end