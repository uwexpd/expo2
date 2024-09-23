# For upgrading to rails 5 
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Prepend the DeepClone module to apply it to all models
  prepend DeepDup
end
