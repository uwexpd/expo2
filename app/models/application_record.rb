# For upgrading to rails 5 
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
