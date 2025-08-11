class ServiceLearningPositionsSectorType < ApplicationRecord
  has_many :service_learning_positions_sector_types_links, :dependent => :destroy
  has_many :service_learning_positions, :through => :service_learning_positions_sector_types_links, :source => :service_learning_position
end