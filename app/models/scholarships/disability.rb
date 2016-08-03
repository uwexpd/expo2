class Disability < ActiveRecord::Base
  establish_connection "uso_#{Rails.env}".to_sym
  
  has_many :scholarship_disability
  
  validates_presence_of :name
  
  # Alias for #name
  def title
    name
  end
  
end