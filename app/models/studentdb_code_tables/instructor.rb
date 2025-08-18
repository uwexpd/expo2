class Instructor < StudentInfo
  self.table_name = "sr_instructor"
  self.primary_keys = :instr_ssn
  has_many :course_instructor, foreign_key: :fac_ssn

  def fullname
    instr_name.strip
  end

  def firstname
    fullname.to_s.split(',')[1].to_s.strip
  end

  def lastname
    fullname.to_s.split(',')[0].to_s.strip
  end

  def email
    unless instr_netid.blank?        
      instr_netid.strip + "@uw.edu"
    end
  end

end 