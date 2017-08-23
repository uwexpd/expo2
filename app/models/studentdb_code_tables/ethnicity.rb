# Ethnic codes
class Ethnicity < StudentInfo
  self.table_name = "sys_tbl_21_ethnic"
  self.primary_key = :table_key

  PLACEHOLDER_CODES = %w(group description long_description under_represented?)
  
  def group
    ethnic_group
  end
  
  def description
    ethnic_desc.strip
  end
  
  def long_description
    ethnic_long_desc.strip
  end
  
  def under_represented?
    ethnic_under_rep == 9
  end
end
