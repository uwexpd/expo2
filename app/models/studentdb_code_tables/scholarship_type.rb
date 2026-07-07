# Scholarship Type Codes
class ScholarshipType < StudentInfo
  self.table_name = "sec.sys_tbl_45_scholarship"
  self.primary_key = :table_key
  
  def description
    scholar_descrip.strip
  end
end
