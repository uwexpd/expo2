namespace :givepulse do
  desc "Fetch Bothell Connected Huskies events JSON and create GivePulse events via API"
  task import_events: :environment do
    require 'faraday'
    require 'json'

    # Fetch events JSON data from UW
    response = Faraday.get('https://depts.washington.edu/uwbur/wp-json/export/v1/hp-listings')

    if response.status == 200
      parsed_json = JSON.parse(response.body)
      events_data = parsed_json["data"] || []
      puts "Fetched #{events_data.size} events."
    else
      puts "Failed to fetch events data: #{response.status}"
      exit 1
    end

    success_count = 0
    failure_count = 0
    failed_titles = []

    # Map and create each event
    events_data.first(5).each do |event|
      # puts "event data: #{event.inspect}"
      # Map fields from UW JSON to GivePulse API params
      full_params = {
        title: event['post_title'] || "No title",
        description: event['post_content'] || "",
        group_id: "921813", # Connected Huskies Group ID
        event_type: "event",
        num_registrants_needed: 2,  # Adjust or map from event if available
        first_name: "Sarah",
        last_name: "Verlinde-Azofeifa",
        email: "severlin@uw.edu",
        address1: event['address'],
        # address2: event['address2'],
        city:     event['city'],
        state:    event['state'],
        zip:      event['zip'],
        is_published: "0"
      }
      # puts "full_params: #{full_params.inspect}"

      # Create event via GivepulseEvent class method
      result = GivepulseEvent.create_event(full_params)

      if result
        success_count += 1
        puts "Created event: #{full_params[:title]}"
      else
        failure_count += 1
        failed_titles << full_params[:title]
        puts "Failed to create event: #{full_params[:title]}"
      end
    end

    puts "Import complete: #{success_count} succeeded, #{failure_count} failed."
    if failure_count > 0
      puts "Failed events: #{failed_titles.join(', ')}"
    end
  end
end