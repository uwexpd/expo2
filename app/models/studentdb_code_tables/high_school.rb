# High School CEEB Code Conversion Table.
# May not be 100% valid
class HighSchool < StudentInfo
  self.table_name = "sys_tbl_30_highschool"
  self.primary_key = :table_key
  
  def name
    high_school_name.strip
  end

  def self.find_by_table_key(key)
    padded_key = key.to_s.rjust(6, '0')
    where(table_key: padded_key).first
  end
  
end