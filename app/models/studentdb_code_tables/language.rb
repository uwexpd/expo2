# Language Codes
class Language < StudentInfo
  self.table_name = "sys_tbl_46_lang_adm"
#  set_primary_keys :table_type, :table_key
  self.primary_key = :table_key
end
