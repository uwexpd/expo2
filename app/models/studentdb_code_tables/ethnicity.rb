# Ethnic codes
class Ethnicity < StudentInfo
  self.table_name = "sys_tbl_21_ethnic"
  self.primary_key = :table_key

  PLACEHOLDER_CODES = %w(group description long_description under_represented?)

  ETHNICITY_GROUP_CODES = {
      1 => 'African American',
      2 => 'American Indian',
      3 => 'White',
      4 => 'Hispanic/Latino',
      5 => 'Asian American',
      6 => 'Hawaiian/Pacific Islander',
      7 => 'Not Indicated',
      99 => 'International'
    }
  
  def self.find_by_table_key(key)
    padded_key = key.to_s.rjust(20, '0')
    where(table_key: padded_key).first
  end

  def group
    ethnic_group
  end

  def group_name    
    ETHNICITY_GROUP_CODES[group] || 'Unknown'
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
