class ScholarshipBase < ActiveRecord::Base  
  self.abstract_class = true
  establish_connection DB_SCHOLARSHIPS
end