# Each Event can have staff members (often volunteers). If a Person has a record in this table, then they have signed up to be an EventStaff for this Event. This association happens via EventStaffPositionShift, which identifies the possible different positions someone can sign up for.
class EventStaff < ApplicationRecord
  stampable
  belongs_to :shift, :class_name => "EventStaffPositionShift", :foreign_key => "event_staff_position_shift_id"
  belongs_to :person
  
  validates_presence_of :event_staff_position_shift_id, :person_id
  validates_uniqueness_of :person_id, :scope => :event_staff_position_shift_id

  validate :no_overlapping_times
  validate :shift_has_capacity, on: :create

  after_create_commit  -> { queue_unit_notification('signed up') }
  after_destroy_commit -> { queue_unit_notification('canceled') }
  

  # If the time for this shift overlaps with another shift for this event that this person is signed up for, then return an error.
  def no_overlapping_times
    return true unless shift.overlaps_other_shifts?
    for other in shift.overlapping_shifts
      errors.add(:base, "This shift overlaps with #{other.position.title} shift #{other.time_detail}") if other.signed_up?(person)
    end
  end

  delegate :position, :to => :shift
  delegate :event, :to => :position
  
  PLACEHOLDER_CODES = %w( )
  PLACEHOLDER_ASSOCIATIONS = %w( person shift event position )
    
  # Sends a confirmation email to the volunteer using the +staff_signup_email_template+ as defined in the Event.
  def send_staff_signup_email
    return nil unless event.staff_signup_email_template
    if person
      email = event.staff_signup_email_template.create_email_to(self)
      EmailContact.log(person, email.deliver_now)
      return email
    end
    nil
  end

  private

  def shift_has_capacity
    return unless shift&.full?

    errors.add(:base, 'This shift is full. Please choose another shift.')
  end

  def notify_unit_of_signup
    enqueue_unit_notification('signup')
  end

  def notify_unit_of_cancellation
    enqueue_unit_notification('cancellation')
  end

  def queue_unit_notification(action)    
    recipient = event.unit&.email
    if recipient.blank?
      Rails.logger.warn("Missing unit notification email for event #{event.id}")
      return
    end

    info = {
      action: action,
      volunteer_name: person.fullname,
      event_title: event.title,
      position_title: position.title,
      shift_time: shift.time_detail,
      shift_id: shift.id
    }

    EventStaffNotificationJob.perform_now(info, recipient)
  end

end 