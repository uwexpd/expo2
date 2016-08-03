class ScholarshipType < ActiveRecord::Base
  establish_connection "uso_#{Rails.env}".to_sym
  
  belongs_to :scholarship
  belongs_to :type
  
end