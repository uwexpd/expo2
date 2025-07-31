class Instructor < StudentInfo
  self.table_name = "sec.sr_instructor"
  self.primary_keys = :instr_ssn
  has_many :course_instructor, foreign_key: :fac_ssn

  def fullname
    instr_name.strip
  end

  def email
    unless instr_netid.blank?        
      instr_netid.strip + "@uw.edu"
    end
  end

end 