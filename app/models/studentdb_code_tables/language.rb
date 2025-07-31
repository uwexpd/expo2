# Language Codes
class Language < StudentInfo
  self.table_name = "sec.sys_tbl_46_lang_adm"
#  set_primary_keys :table_type, :table_key
  self.primary_key = :table_key

  def self.find_by_table_key(key)
    padded_key = key.to_s.rjust(6, '0')
    where(table_key: padded_key).first
  end
  
end
