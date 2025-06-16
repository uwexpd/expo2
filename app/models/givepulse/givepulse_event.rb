class GivepulseEvent < GivepulseBase
  include ActiveModel::Model

  attr_accessor :id, :created, :modified, :title, :description, :group_id, :group_title, :organizer_id, :event_type, :kind_of_event, :num_registrants_needed, :num_registrants, :num_people, :start_date_time, :end_date_time, :registration_close_datetime, :is_submission, :is_published, :cancelled, :first_name, :last_name, :email, :address1, :address2, :city, :state, :zip, :latitude, :longitude, :end_address1, :end_address2, :end_city, :end_state, :end_zip, :end_latitude, :end_longitude, :parking_details, :requirements, :perks, :website, :facebook_url, :snapchat_id, :instagram_id, :twitter_id, :image, :cover_image, :featured_media, :privacy_level, :tags, :administrative_fields, :address_description, :end_address_description

  PERMITTED_ATTRS = instance_methods(false).grep(/=$/).map { |m| m.to_s.chomp('=') }

   # Simulate ActiveRecord's where method. e.g.: where(id: "226983")
  def self.where(attributes)
    begin
      response = request_api('/events', attributes, method: :get)      
      response = JSON.parse(response.body)
      # Rails.logger.debug("Json Response received: #{response}")

      if response['total'].to_i > 0
        results = response['results']
        events = results.map { |attrs| new(attrs.slice(*permitted_attrs)) }
      else
        Rails.logger.warn("No events found with attributes: #{attributes}")
        nil
      end
    rescue StandardError => e
      Rails.logger.error("Error fetching events: #{e.message}")
      nil
    end
  end

  def self.create_event(params = {})

    # Test case with a EXPO position ID: 36323
    import_position = ServiceLearningPosition.find(36189)
    
    # Add default params or merge with existing ones
    full_params = { title: import_position.title,
                    description: "Context: " + import_position.context_description + "<br> Work Description:  "  + import_position.description + "<br> Impact: " + import_position.impact_description,
                    group_id: "792620", # "811206",
                    event_type: "event",
                    num_registrants_needed: import_position.ideal_number_of_slots,
                    # requirements: "backgroundcheck",
                    # requirement_details: import_position.skills_requirement.encode("Windows-1252").force_encoding('UTF-8'),
                    is_published: "0"
                  }.merge(params)

    begin
      Rails.logger.debug("create_event full_params: #{full_params}")
      response = request_api("/events", full_params, method: :post)
      Rails.logger.debug("create_event Response received: #{response}")

      if response.code.to_i == 200
        response_body = JSON.parse(response.body)
        Rails.logger.debug("Debug response=> #{response_body}")
        Rails.logger.info("Successfully created new event: #{response_body["event_id"]}")
        true
      else
        Rails.logger.warn("Failed to create event: #{response}")
        false
      end
    rescue StandardError => e
      Rails.logger.error("Error creating event: #{e.message}")
      false
    end
  end


end