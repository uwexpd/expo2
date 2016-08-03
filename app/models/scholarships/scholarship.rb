class Scholarship < ActiveRecord::Base
  establish_connection "uso_#{Rails.env}".to_sym
  
  has_many :scholarship_categories
  has_many :scholarship_deadlines
  has_many :scholarship_disabilities
  has_many :scholarship_ethnicities
  has_many :scholarship_type
  
  def scholarship_type_name
    scholarship_type.collect{|t|t.type.title}
  end

  
end
