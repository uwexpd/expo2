# Models a type of activity, e.g., "Public Service" or "Undergraduate Research"
class ActivityType < ApplicationRecord
  validates_presence_of :title
  validates_presence_of :abbreviation
  validates_uniqueness_of :abbreviation
  
  has_many :activities
  
end