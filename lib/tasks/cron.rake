namespace :cron do
  namespace :service_learning do
    desc "Unplace students who are placed in service-learning positions for the current quarter but no longer enrolled in the associated course(s)."
    task unplace_unenrolled_students: :environment do
      STDOUT.sync = true
      puts "Finding placements with unenrolled students..."

      # If you still need this for MySQL, keep it; otherwise you can remove it.
      # Prefer session-only changes to avoid surprising global behavior.
      ActiveRecord::Base.connection.execute("SET SESSION sql_mode = 'ANSI'")

      quarter = Quarter.current_quarter
      placements = quarter.service_learning_placements

      placements.find_each do |p|
        next unless p.filled? && p.allocated?

        enrolled_courses = p.person.enrolled_service_learning_courses(quarter, nil)
        next if enrolled_courses.include?(p.course)

        puts "Un-placing student: #{p.id}, #{p.person.fullname}"

        # Reload inside the transaction to avoid stale objects if needed
        ServiceLearningPlacement.transaction do
          placement = ServiceLearningPlacement.find(p.id)

          # deep_clone! is not Rails; keep if your app provides it (e.g., deep_cloneable).
          new_placement = placement.deep_clone!
          new_placement.update!(person_id: nil)

          placement.destroy!
        end

        puts "done.\n\n"
      end
    end
  end

  namespace :equipment_reservations do
    desc "Process late returns (daily at 4 pm)"
    task process_late_returns: :environment do
      STDOUT.sync = true
      puts "Processing late returns..."
      EquipmentReservationSweeper.process_late_returns
    end

    desc "Send tomorrow reminders (daily at 6 pm)"
    task tomorrow_reminders: :environment do
      STDOUT.sync = true
      puts "Sending tomorrow's reminders..."
      EquipmentReservationSweeper.tomorrow_reminders
    end

    desc "Send equipment not ready check (daily at 9 am)"
    task equipment_not_ready_check: :environment do
      STDOUT.sync = true
      puts "Sending equipment not ready checks..."
      EquipmentReservationSweeper.equipment_not_ready_check
    end
  end

  namespace :users do
    desc "Remove old session history"
    task remove_old_session_history: :environment do
      STDOUT.sync = true
      puts "Removing session history older than one month..."
      deleted = SessionHistory.where("created_at < ?", 1.month.ago).delete_all
      puts "Deleted #{deleted} rows."
    end
  end

  namespace :sessions do
    desc "Remove expired sessions"
    task remove_expired_sessions: :environment do
      STDOUT.sync = true
      puts "Removing sessions that are not updated within one day or are created older than two days ago.."
      deleted = Session.sweep
      puts "Deleted #{deleted} rows."
    end
  end

  namespace :events do
    desc "Send reminder to users who RSVP the events"
    task send_reminders: :environment do
      STDOUT.sync = true
      puts "Sending reminders to users..."
      Event.send_reminders.find_each { |e| e.send_attendee_reminder! }
    end
  end
end