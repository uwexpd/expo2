require 'logger'

class CanvasApiClient
  CANVAS_API_BASE_URL = 'https://canvas.uw.edu/api/v1'

  def initialize(access_token = ENV['CANVAS_API_TOKEN'])
    raise ArgumentError, "Canvas API token is missing" if access_token.nil? || access_token.empty?

    @access_token = access_token
    @connection = Faraday.new(url: CANVAS_API_BASE_URL) do |conn|
      conn.request :json
      # conn.response :logger, Logger.new(STDOUT), bodies: true  # Log request and response bodies
      conn.response :json, content_type: /\bjson$/
      conn.adapter Faraday.default_adapter
    end
  end

  # Generic method to fetch all paginated results from a given relative path
  def fetch_all_pages(path)
    results = []
    url = path

    loop do
      response = @connection.get(url) do |req|
        req.headers['Authorization'] = "Bearer #{@access_token}"
      end

      results.concat(handle_response(response))

      next_link = parse_next_link(response.headers['link'])
      break unless next_link

      # Convert absolute next_link URL to relative path for Faraday
      url = URI(next_link).request_uri.sub('/api/v1/', '')
    end

    results
  end


  def get_course(course_id)    
    response = @connection.get("courses/#{course_id}") do |req|
      req.headers['Authorization'] = "Bearer #{@access_token}"      
    end
    handle_response(response)
  end

  # Use this helper in your enrollments method:
  def get_enrollments_for_course(course_id)
    raise ArgumentError, "course_id is required" if course_id.nil? || course_id.to_s.strip.empty?

    fetch_all_pages("courses/#{course_id}/enrollments")
  end

  private

  def parse_next_link(link_header)
    return nil if link_header.nil?

    links = link_header.split(',').map(&:strip)
    next_link = links.find { |l| l =~ /rel="next"/ }
    return nil unless next_link

    next_link[/<(.*?)>/, 1]
  end

  def handle_response(response)
    if response.success?
      response.body
    else
      raise "Canvas API Error: #{response.status} - #{response.body}"
    end
  end
end