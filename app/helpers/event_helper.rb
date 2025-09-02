module EventHelper
  def google_calendar_url(event, time)
    start_time = time.start_time.utc.strftime("%Y%m%dT%H%M%SZ")
    end_time   = time.end_time.utc.strftime("%Y%m%dT%H%M%SZ")

    "https://www.google.com/calendar/render?" +
      {
        action:     "TEMPLATE",
        text:       event.title,
        dates:      "#{start_time}/#{end_time}",
        details:    event.description,
        location:   time.location_text
      }.to_query
  end
end
