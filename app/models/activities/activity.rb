=begin rdoc
An Activity models a person's participation in some sort of trackable activity. The primary purpose of the Activity models is to compile and generate accountability statistics for the provost and the legislature. We currently focus on two metrics for undergraduates: public service and research.

== How activities are stored
Activity is subclassed by a number of Activity varieties:

ActivityCourse::    for tracking an entire UW course for a particular quarter
ActivityProject::   for tracking an ongoing project, such as Students in Service, that lasts several weeks or even several quarters
ActivityEvent::     for tracking a one-time event, such as the MLK Day of Service, that has a more limited scope.
=end
class Activity < ApplicationRecord
  stampable

  belongs_to :department

  validates :activity_type_id, presence: true
  validates_associated :quarters
  has_many :quarters, class_name: 'ActivityQuarter', dependent: :destroy

  # Constants
  COURSE_CREDIT_TO_HOURS_MULTIPLIER = 3
  WEEKS_PER_QUARTER = 10
  SERVICE_LEARNING_PLACEMENT_NUMBER_OF_HOURS = 20

  # Scopes
  scope :for_quarter, ->(q) {
    quarter_ids = q.is_a?(Array) ? q.map(&:id) : q.id
    select('DISTINCT activities.*').where(quarter_id: quarter_ids)
  }

  scope :of_type, ->(t) {
    activity_type_id = case t
                       when String
                         ActivityType.find_by(abbreviation: t)&.id
                       when ActivityType
                         t.id
                       else
                         t
                       end
    select('DISTINCT activities.*').where(activity_type_id: activity_type_id)
  }

  # Calculates the number of hours for a given activity source
  def self.number_of_hours(source)
    return source.number_of_hours if source.respond_to?(:number_of_hours)

    case source
    when StudentRegistrationCourse
      source.credits * COURSE_CREDIT_TO_HOURS_MULTIPLIER * WEEKS_PER_QUARTER
    when ServiceLearningPlacement
      SERVICE_LEARNING_PLACEMENT_NUMBER_OF_HOURS
    else
      nil
    end
  end
end



