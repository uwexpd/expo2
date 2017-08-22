# College Codes
class College < StudentInfo
  self.table_name = "sr_coll_code"
  self.primary_keys = :college_branch, :college_code
  
  def name
    college_name
  end
  
end
