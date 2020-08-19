class ScholarshipBase < ApplicationRecord  
  self.abstract_class = true
  establish_connection DB_SCHOLARSHIPS
end