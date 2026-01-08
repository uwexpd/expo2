class GivepulseEvent < GivepulseBase
  include ActiveModel::Model

  attr_accessor :id, :created, :modified, :title, :description, :group_id, :group_title, :organizer_id, :event_type, :kind_of_event, :num_registrants_needed, :num_registrants, :num_people, :start_date_time, :end_date_time, :registration_close_datetime, :is_submission, :is_published, :cancelled, :first_name, :last_name, :email, :address1, :address2, :city, :state, :zip, :latitude, :longitude, :end_address1, :end_address2, :end_city, :end_state, :end_zip, :end_latitude, :end_longitude, :parking_details, :requirements, :perks, :website, :facebook_url, :snapchat_id, :instagram_id, :twitter_id, :image, :cover_image, :featured_media, :privacy_level, :tags, :administrative_fields, :address_description, :end_address_description

  PERMITTED_ATTRS = instance_methods(false).grep(/=$/).map { |m| m.to_s.chomp('=') }

   # Simulate ActiveRecord's where method. e.g.: GivepulseEvent.where(group_id: 1479596)
  def self.where(attributes)
    begin
      results = fetch_all_records('/events', attributes)

      if results.empty?
        Rails.logger.warn("No events found with attributes: #{attributes}")
        []
      else
        results.map { |attrs| new(attrs.slice(*permitted_attrs)) }
      end
    rescue StandardError => e
      Rails.logger.error("Error fetching events: #{e.message}")
      []
    end
  end

  # Eg: Import events for Seattle CEC: GivepulseEvent.create_events(36265, group_id: 792610)
  # GivepulseEvent.create_events([35914, 35919, 36256, 36257, 36258, 36259, 36260], group_id: 1479577)
  def self.create_events(ids, params = {})

    begin
      import_positions =  ServiceLearningPosition.where(id: ids)
    rescue ActiveRecord::RecordNotFound
      import_positions = []
    end

    success_count = 0
    failure_count = 0
    failed_ids = []

    Rails.logger.info("Start to import #{import_positions.size} positions")

    import_positions.each do |import_position|
      # Build merged params for each position
      # full_params = {
      #   title: import_position.title,
      #   description: "Context: #{import_position.context_description}<br> Work Description: #{import_position.description}<br> Impact: #{import_position.impact_description}",
      #   # group_id: "792620", # or "811206", Check Group ID for CEC campus groups
      #   event_type: "event",
      #   num_registrants_needed: import_position.ideal_number_of_slots,
      #   # requirements: "backgroundcheck",
      #   # requirement_details: import_position.skills_requirement.encode("Windows-1252").force_encoding('UTF-8'),
      #   is_published: "0"
      # }.merge(params)

      requirements = []
      requirements << "#{import_position.age_requirement} #{'('+import_position.other_age_requirement+')' if import_position.has_other_age_requirement? && import_position.other_age_requirement} years old" unless import_position.age_requirement.blank?
      requirements << "Must commit for #{import_position.duration_requirement}" unless import_position.duration_requirement.blank?
      requirements << "TB test required" if import_position.tb_test_required?
      requirements << "Flu vaccination required<br>" if import_position.flu_vaccination_required?
      requirements << "Valid food handler’s permit required" if import_position.food_permit_required?
      requirements << "Other health screenings or certifications required: #{import_position.other_health_requirement}" if import_position.other_health_required? && import_position.other_health_requirement
      requirements << "Other paperwork: #{import_position.paperwork_requirement}" unless import_position.paperwork_requirement.blank?

      requirements_string = requirements.join("<br>")

      if import_position.background_check_required?
        background_check_details = []

        background_check_details << "Full legal name required" if import_position.legal_name_required?
        background_check_details << "Birthdate required" if import_position.birthdate_required?
        background_check_details << "Social security number required" if import_position.ssn_required?
        background_check_details << "Fingerprinting required" if import_position.fingerprint_required?
        background_check_details << "Other background required: #{import_position.other_background_check_requirement}" if import_position.other_background_check_required? && import_position.other_background_check_requirement
        background_check_details << "This site is not able to accommodate international students, due to the length of time and cost required to complete international background checks<br>" if import_position.non_intl_student_required?

        background_check_string = background_check_details.join("<br>")
      end

      sectors = import_position.service_learning_positions_sector_types.map(&:name).join(', ')
      languages_spoken = import_position.pipeline_positions_language_spokens.map(&:name).join(', ')

      subjects = import_position.pipeline_positions_subjects.map(&:name).join(', ')
      grade_levels = import_position.pipeline_positions_grade_levels.map(&:name).join(', ')
      tutoring_formats = import_position.pipeline_positions_tutoring_types.map(&:name).join(', ') 


      description_html =
        "*********** DESCRIPTION ***********<br><br>" +
        "#{import_position.organization.name.strip rescue nil}" + 
        "<b>Work Description:</b>" +
        "#{import_position.context_description}<br>" +
        "#{import_position.description}<br>" +
        "#{import_position.impact_description}<br><br>" +
        
        "<b>Supervisor:</b>" +
        "#{import_position.supervisor.fullname rescue nil} - " +
        "#{import_position.supervisor.person.email rescue nil} - " +
        "#{import_position.supervisor.person.phone rescue nil}<br><br>" +
        
        "<b>Location:</b>" +
        "#{import_position.location.title rescue nil}<br>" +
        
        "<b>Location Notes:</b>" +
        "#{[import_position.location.bus_directions, import_position.location.driving_directions].compact.join('<br>') rescue nil}<br><br>" +
        
        "<b>Alternate Transportation:</b>" +
        "#{import_position.alternate_transportation}<br><br>" +
        
        "<b>Length of commitment:</b>" +
        "#{import_position.duration_requirement}<br><br>" +
        
        "<b>Times:</b>" +
        "#{import_position.timecodes.join(', ')}<br><br>" +
        
        "<b>Time notes:</b>" +
        "#{import_position.time_notes}<br><br>" +
        
        "*********** REQUIREMENTS ***********<br><br>" +
        
        "<b>Requirements:</b>" +
        "#{requirements_string}<br><br>" +
        
        "<b>Skills Needed:</b>" +
        "#{import_position.skills_requirement}<br><br>" +
        
        "<b>Any health screenings and certifications:</b>" +
        "#{position_health_requirements_string rescue nil}<br><br>" +
        
        "<b>Background checks:</b>" +
        "#{background_check_string rescue nil}<br><br>" +
        
        "<b>Other Required paperwork?:</b>" +
        "#{import_position.paperwork_requirement}<br><br>" +
        
        "<b>Orientation Contact:</b>" +
        "#{import_position.orientation.contact_name rescue nil} - " +
        "#{import_position.orientation.contact_email rescue nil}<br><br>" +
        
        "<b>Orientation Location:</b>" +
        "#{import_position.orientation.location.title rescue nil}<br><br>" +
        
        "<b>Orientation Notes:</b>" +
        "#{import_position.orientation.notes rescue nil}<br><br>" +
        
        "*********** OTHER INFO ***********<br><br>" +
        
        "<b>Sectors:</b>" +
        "#{sectors}<br>" +
        
        "<b>Languages Spoken:</b>" +
        "#{languages_spoken}<br><br>" +
        
        "<b>Education Sectors:</b><br>" +
        "<b>Subjects:</b>" +
        "#{subjects}<br><br>" +
        
        "<b>Grade Levels:</b>" +
        "#{grade_levels}<br><br>" +
        
        "<b>Tutoring Formats:</b>" +
        "#{tutoring_formats}<br>"

      description_html = description_html.html_safe

      # POST Params
      full_params = {
        title: "IMPORTED: #{import_position.title}".truncate(140 - "IMPORTED: ".length),
        description: description_html,        
        event_type: "event",
        num_registrants_needed:  import_position&.ideal_number_of_slots,
        address1: import_position.location&.address_line_1,
        address2: import_position.location&.address_line_2,
        city:     import_position.location&.address_city,
        state:    import_position.location&.address_state,
        zip:      import_position.location&.address_zip,
        is_published: "0"
      }.merge(params)

#"Work Description: #{import_position.description} #{import_position.context_description} #{import_position.impact_description}<br> Supervisor: #{import_position.supervisor.fullname rescue nil} - #{import_position.supervisor.person.email rescue nil} - #{import_position.supervisor.person.phone rescue nil}<br><br> Requirements:<br> #{requirements_string} <br> Background Check Required: #{background_check_string rescue nil}<br> Skills Needed: #{import_position.skills_requirement.html_safe}<br> Location: #{import_position.location.title}<br> #{import_position.location.bus_directions}<br> #{import_position.location.driving_directions} <br> Orientation: #{import_position.orientation.notes.html_safe} <br>Time:<br> #{import_position.timecodes.join(", ")}<br> #{import_position.times_are_flexible}<br> #{import_position.time_notes}<br> Alternate Transportation: #{import_position.alternate_transportation}<br><br> Sectors: #{sectors}<br> Languages Spoken: #{languages_spoken}<br><br> Education Sectors:<br> Subjects: #{subjects} <br> Grade Levels: #{grade_levels}<br> Tutoring Formats: #{tutoring_formats}",

      begin
        #Rails.logger.debug("create_event full_params: #{full_params}")
        response = request_api("/events", full_params, method: :post)
        #Rails.logger.debug("create_event Response received: #{response}")

        if response.code.to_i == 200
          response_body = JSON.parse(response.body)
          Rails.logger.info("Successfully created new event: #{response_body["event_id"]}")
          success_count += 1
        else
          Rails.logger.warn("Failed to create event for position #{import_position.id}: #{response}")
          failure_count += 1
          failed_ids << import_position.id
        end
      rescue StandardError => e
        Rails.logger.error("Error creating event for position #{import_position.id}: #{e.message}")
        failure_count += 1
        failed_ids << import_position.id
      end
    end
    
    Rails.logger.info("Event creation completed: #{success_count} success, #{failure_count} failed.")
    Rails.logger.info("Failed IDs: #{failed_ids.join(', ')}") unless failed_ids.empty?
  end



end