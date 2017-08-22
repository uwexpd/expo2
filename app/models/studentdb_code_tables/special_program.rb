# Special Program Codes (unknown?)
class SpecialProgram < StudentInfo
  self.table_name = "sys_tbl_34_spcl_pgm"
  # set_primary_keys :table_type, :table_key
  self.primary_key = :table_key
  
  PLACEHOLDER_CODES = %w(description)
  
  def description
    sp_pgm_descrip.strip
  end
end
