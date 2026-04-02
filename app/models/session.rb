class Session < ApplicationRecord
  # Deletes sessions not updated since `time` OR created more than 2 days ago.
  # Accepts:
  # - Time/DateTime/ActiveSupport::TimeWithZone
  # - ActiveSupport::Duration (e.g., 1.day)
  # - Integer seconds
  # - String like "1 day" / "2 hours" (best-effort)
  def self.sweep(time = 1.day.ago)
    cutoff =
      case time
      when String
        # "1 day", "2 hours", "15 minutes"
        amount, unit = time.strip.split(/\s+/, 2)
        amount = amount.to_i
        unit = unit.to_s.singularize

        duration =
          case unit
          when "second" then amount.seconds
          when "minute" then amount.minutes
          when "hour"   then amount.hours
          when "day"    then amount.days
          when "week"   then amount.weeks
          when "month"  then amount.months
          when "year"   then amount.years
          else
            raise ArgumentError, "Unsupported time string: #{time.inspect}"
          end

        Time.current - duration
      when ActiveSupport::Duration
        Time.current - time
      when Integer
        Time.current - time
      else
        time
      end

    where("updated_at < ? OR created_at < ?", cutoff, 2.days.ago).delete_all
  end
end