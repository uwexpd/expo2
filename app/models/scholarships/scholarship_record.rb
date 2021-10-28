class ScholarshipRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection :"scholarship_#{Rails.env}"
end
