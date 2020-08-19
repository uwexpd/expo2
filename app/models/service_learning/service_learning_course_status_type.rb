# Tracks the possible status types for ServiceLearningCourseStatus.
class ServiceLearningCourseStatusType < ApplicationRecord
  stampable
  has_many :service_learning_course_statuses
  
  validates_presence_of :title
  
end
