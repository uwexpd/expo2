# High School CEEB Code Conversion Table.
# May not be 100% valid
class HighSchool < StudentInfo
  self.table_name = "sys_tbl_30_highschool"
  self.primary_key = :table_key
  
  def name
    high_school_name.strip
  end
  
end