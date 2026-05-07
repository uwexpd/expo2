ActiveAdmin.register_page "Stats" do
  menu priority: 30, label: "<i class='mi'>analytics</i> Stats".html_safe

  page_action :query, method: :get do
    # just render page content; params available in view
  end

  page_action :resolve_conflicts, method: :post do
    q = params[:q].to_s
    redirect_to admin_stats_query_path, alert: "Please paste at least one identifier." and return if q.blank?

    if params[:commit] == "Proceed"
      found_ids = params[:found].to_s.split(",").map(&:strip).reject(&:blank?)
      @found = StudentRecord.where(id: found_ids)

      @not_found = params[:not_found].to_s.split(/[\r\n]+/).map(&:strip).reject(&:blank?)

      remaining_conflicts = params[:conflicts].to_s.split(/[\r\n]+/).map(&:strip).reject(&:blank?)
      Array(params[:conflict_removals]).each { |x| remaining_conflicts.delete(x) }

      if params[:conflict_resolutions].present?
        params[:conflict_resolutions].each do |query_string, new_system_key|
          remaining_conflicts.delete(query_string)
          @found = @found.to_a << StudentRecord.find(new_system_key)
        end
      end

      @conflicts = {}
      populate_conflict_arrays(remaining_conflicts)
    else
      @found = []
      @not_found = []
      @conflicts = {}
      populate_conflict_arrays(q.split(/[\r\n]+/))
    end

    # If no conflicts remain, create a ManualPopulation (same as old flow)
    if @conflicts.empty?
      p = ManualPopulation.new
      p.title = params[:title].presence || "Manual Student Query #{Time.current.to_i}"
      p.access_level = "creator"
      p.creator_id = current_admin_user.try(:id) # ActiveAdmin uses current_admin_user by default
      p.system = true if params[:title].blank?

      p.object_ids = {}
      Array(@found).each do |r|
        p.object_ids[r.class.to_s.to_sym] ||= []
        p.object_ids[r.class.to_s.to_sym] << r.id
      end

      # ensure unique title if validation requires it
      while !p.valid? && p.errors[:title].present?
        if p.title[/\d+$/].nil?
          p.title += " 2"
        else
          new_num = p.title[/\d+$/].to_i + 1
          p.title.gsub!(/\d+$/, new_num.to_s)
        end
      end

      if p.save
        redirect_to admin_stats_population_path(id: p.id) and return
      else
        redirect_to admin_stats_query_path, alert: "There was an error saving your query." and return
      end
    end

    render "admin/stats/resolve_conflicts"
  end

  page_action :population, method: :get do
    @population = Population.find(params[:id])
    @title = @population.title

    stats = generate_results(@population.objects)
    assign_stats_ivars(stats)

    render "admin/stats/result"
  end

  page_action :result, method: :post do
    students = params.dig(:stats, :students).to_s.split
    @title = params.dig(:stats, :title)

    stats = generate_results(students)
    assign_stats_ivars(stats)

    render "admin/stats/result"
  end  

  # app/admin/stats.rb (inside ActiveAdmin.register_page "Stats" do... end)

  page_action :overview, method: :get do
    @start_quarter = Quarter.find(params[:start_quarter_id].presence || Quarter.current_quarter.prev.prev.prev.prev.id)
    @end_quarter   = Quarter.find(params[:end_quarter_id].presence   || Quarter.current_quarter.id)
    @students_only = params[:students_only].present?

    range = @start_quarter.first_day..@end_quarter.next.first_day

    @event_types = EventType.all.to_a
    @units       = Unit.includes(:users).to_a
    unit_ids     = @units.map(&:id)

    # EventTime does NOT have unit_id. Unit is on events.unit_id.
    event_times = EventTime.joins(:event).where(events: { unit_id: unit_ids }).where(start_time: range).includes(event: :event_type, attended: :person)

    appointments = Appointment.where(unit_id: unit_ids, start_time: range).includes(:student, :staff_person)

    unit_staff_person_ids = @units.each_with_object({}) do |unit, h|
      h[unit.id] = unit.users.map(&:person_id).compact
    end

    @overview = build_overview_table(
      units: @units,
      event_types: @event_types,
      event_times: event_times,
      appointments: appointments,
      unit_staff_person_ids: unit_staff_person_ids,
      students_only: @students_only
    )

    render "admin/stats/overview"
  end

  controller do
    def index
      redirect_to admin_stats_overview_path
    end

    # --- Conflict resolution helpers ---
    def populate_conflict_arrays(collection)
      @found ||= []
      @not_found ||= []
      @conflicts ||= {}

      Array(collection).each do |q|
        q = q.to_s.strip
        next if q.blank?

        sr =
          if q.include?(" ") || q.include?(",")
            StudentRecord.find_by_name(q, 15, false, true)
          elsif q.match?(/\A[+-]?\d+(\.\d+)?\z/)
            StudentRecord.find_by_student_no(q)
          else
            StudentRecord.find_by_uw_netid(q)
          end

        if sr.nil? || (sr.is_a?(Array) && sr.empty?)
          @not_found << q
        elsif sr.is_a?(Array) && sr.size > 1
          @conflicts[q] = sr.flatten
        elsif sr.is_a?(Array) && sr.size == 1
          @found << sr.first
        else
          @found << sr
        end
      end
    end

    # --- Stats generation (ported from your controller) ---
    def generate_results(collection)
      students = []
      duplicate_count = 0
      errors = []
      under_rep_students = []
      eop_students = []
      ethnicities = Hash.new(0)
      ages = Hash.new(0)
      genders = Hash.new(0)
      discipline_categories = {} # { DisciplineCategory => [count, {major => count}] }

      Array(collection).each do |n|
        student_to_add = nil

        if n.is_a?(Student)
          student_to_add = n
        elsif n.respond_to?(:person) || n.respond_to?(:student)
          if n.respond_to?(:person) && n.person.is_a?(Student)
            student_to_add = n.person
          elsif n.respond_to?(:student) && n.student.is_a?(Student)
            student_to_add = n.student
          else
            errors << n
          end
        elsif n.is_a?(String)
          s = n.strip
          student_to_add =
            if s.match?(/\A[+-]?\d+(\.\d+)?\z/)
              Student.find_by_student_no(s)
            else
              Student.find_by_uw_netid(s)
            end
        else
          errors << n
        end

        if students.include?(student_to_add)
          duplicate_count += 1
        else
          students << student_to_add unless student_to_add.nil?
          errors << n if student_to_add.nil? && n.present?
        end
      end

      students.each do |s|
        next unless s&.sdb

        under_rep_students << s if s.sdb.ethnicity&.under_represented?
        eop_students << s if s.sdb.special_program&.description == "EOP 1"

        ethnicities[s.sdb.ethnicity&.description || "Unknown"] += 1
        ages[s.age || "Unknown"] += 1
        genders[s.gender || "Unknown"] += 1

        Array(s.sdb.majors).each do |m|
          dc = m.discipline_category || DisciplineCategory.unknown
          discipline_categories[dc] ||= [0, Hash.new(0)]
          discipline_categories[dc][0] += 1
          discipline_categories[dc][1][m.major] += 1
        end
      end

      {
        students: students,
        duplicate_count: duplicate_count,
        errors: errors,
        under_rep_students: under_rep_students,
        eop_students: eop_students,
        ethnicities: ethnicities.sort.to_h,
        ages: ages.sort_by { |k, _| k.to_s }.to_h,
        genders: genders.sort.to_h,
        discipline_categories: discipline_categories
      }
    end

    def assign_stats_ivars(stats)
      @students = stats[:students]
      @duplicate_count = stats[:duplicate_count]
      @errors = stats[:errors]
      @under_rep_students = stats[:under_rep_students]
      @eop_students = stats[:eop_students]
      @ethnicities = stats[:ethnicities]
      @ages = stats[:ages]
      @genders = stats[:genders]
      @discipline_categories = stats[:discipline_categories]
    end

    # returns a hash with rows + totals ready for the view
    def build_overview_table(units:, event_types:, event_times:, appointments:, unit_staff_person_ids:, students_only:)
      # Structure:
      # rows[unit_id][:event_counts][event_type_id or 0] = { total: Integer, unique_people: Set, detail: String }
      # rows[unit_id][:appointments] = { total:, unique_students:Set, detail:String }
      # rows[unit_id][:quick_contacts] = { total: Integer }  # not included in unique students
      # rows[unit_id][:unique_students] = Set

      require "set"

      rows = {}
      totals = {
        event_unique_by_type: Hash.new { |h, k| h[k] = Set.new }, # key: event_type_id or 0
        appointment_unique_students: Set.new,
        quick_contact_total: 0,
        all_unique_students: Set.new
      }

      units.each do |unit|
        rows[unit.id] = {
          unit: unit,
          event_counts: Hash.new { |h, k| h[k] = { total: 0, detail_items: [] } }, # k: event_type_id or 0
          appointments: { total: 0, detail_by_staff: Hash.new(0), unique_students: Set.new },
          quick_contacts: { total: 0 },
          unique_students: Set.new
        }
      end

      # ---- Events ----
      # Group event_times by unit_id and event_type_id (nil => 0)
      event_times.each do |et|
        unit_id = et.event&.unit_id
        next unless unit_id && rows.key?(unit_id)

        type_key = et.event&.event_type_id || 0

        attended = Array(et.attended)
        attended = attended.select { |a| a.person.is_a?(Student) } if students_only

        count = attended.size
        next if count.zero?

        people = attended.map(&:person).compact
        person_ids = people.map(&:id)

        rows[unit_id][:event_counts][type_key][:total] += count
        rows[unit_id][:event_counts][type_key][:detail_items] << "#{et.event.title} (#{et.time_detail(date_only: true)}): #{count}"

        # unique student rollups
        rows[unit_id][:unique_students].merge(person_ids)
        totals[:all_unique_students].merge(person_ids)

        totals[:event_unique_by_type][type_key].merge(person_ids)
      end

      # ---- Contacts (Appointments + QuickContacts) ----
      appointments.each do |appt|
        unit_id = appt.unit_id
        next unless rows.key?(unit_id)

        staff_ids = unit_staff_person_ids[unit_id]
        staff_ok = staff_ids.present? ? staff_ids.include?(appt.staff_person_id) : true
        # old condition was "(staff in unit users) OR unit_id = ?"
        # since we already filter by unit_id, staff_ok is effectively always true;
        # keep it in case your data includes cross-unit appointments.
        next unless staff_ok || appt.unit_id == unit_id

        if appt.type == "QuickContact"
          rows[unit_id][:quick_contacts][:total] += 1
          totals[:quick_contact_total] += 1
          next
        end

        rows[unit_id][:appointments][:total] += 1
        rows[unit_id][:appointments][:detail_by_staff][appt.staff_person_id] += 1 if appt.staff_person_id

        student = appt.student
        if student.present?
          rows[unit_id][:appointments][:unique_students].add(student.id)
          rows[unit_id][:unique_students].add(student.id)

          totals[:appointment_unique_students].add(student.id)
          totals[:all_unique_students].add(student.id)
        end
      end

      # finalize details
      rows.each_value do |r|
        r[:appointments][:detail_items] =
          r[:appointments][:detail_by_staff].map do |staff_person_id, count|
            next if count.zero?
            name = Person.find_by(id: staff_person_id)&.fullname || "Staff ##{staff_person_id}"
            "#{name}: #{count}"
          end.compact
      end

      {
        event_types: event_types,
        rows: rows.values,
        totals: {
          event_unique_by_type: totals[:event_unique_by_type].transform_values(&:size),
          appointment_unique_students: totals[:appointment_unique_students].size,
          quick_contact_total: totals[:quick_contact_total],
          all_unique_students: totals[:all_unique_students].size
        }
      }
    end
  
  end # end of controller

end