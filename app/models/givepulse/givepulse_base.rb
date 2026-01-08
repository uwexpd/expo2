class GivepulseBase < ActiveResource::Base
  
  def self.site
    if defined?(@site) && @site.present?
      @site
    else
      Rails.env.production? ? 'https://api2.givepulse.com' : 'https://api2-dev.givepulse.com'
    end
  end

  def self.site=(value)
    @site = value
  end
  
  class << self
    # Store headers in a class-level instance variable
    def givepulse_headers
      @givepulse_headers ||= { 'Content-Type' => 'application/json' }
    end

    # Override headers to include Authorization token dynamically
    def headers
      setup_authorization if givepulse_headers['Authorization'].nil?
      givepulse_headers
    end

    # Setup Authorization if not already set
    # Allow temporary overrides
    def setup_authorization(custom_site: nil, custom_basic_token: nil)
      # temporarily override site if passed
      self.site = custom_site if custom_site.present?

      # decide token source
      env_token =
        if custom_basic_token.present?
          custom_basic_token
        elsif Rails.env.production?
          ENV['GIVEPULSE_PRO_TOKEN']
        else
          ENV['GIVEPULSE_BASIC_TOKEN']
        end

      basic_token = env_token || raise('GIVEPULSE TOKEN is not set!')
      connection = ActiveResource::Connection.new(site)

      auth_response = connection.post(
        '/auth',
        nil,
        { "Authorization" => "Basic #{basic_token}", "Content-Type" => "application/json" }
      )

      if auth_response&.response&.code.to_i == 200 && auth_response&.body.present?
        token = JSON.parse(auth_response.body)['token']
        raise 'Token missing in authorization response' if token.blank?
        givepulse_headers['Authorization'] = "Bearer #{token}"
      else
        Rails.logger.error("Authorization failed: #{auth_response.response.message}")
        raise 'Authorization failed: Invalid response from /auth endpoint'
      end
    end    

    # Make API requests with support for GET, POST, PUT, and DELETE
    def request_api(path, params = {}, method: :get, custom_headers: {})
      begin
        #Rails.logger.debug("request_api Site: #{site}")
        connection = ActiveResource::Connection.new(site)
      
        full_path = params.present? && [:get, :delete].include?(method) ? "#{path}?#{params.to_query}" : path
         # Rails.logger.debug("Making #{method.upcase} request to: #{full_path}")
         # Rails.logger.debug("Request Headers: #{headers}")
         # Rails.logger.debug("Request Params: #{params.to_json}") if method != :get && params.present?

        case method
        when :get
          response = connection.get(full_path, headers)
        when :post
          response = connection.post(full_path, params.to_json, headers.merge(custom_headers))
        when :put
          response = connection.put(full_path, params.to_json, headers.merge(custom_headers))
        when :delete
          full_path = "#{path}?#{params.to_query}"
          response = connection.delete(full_path, headers.merge(custom_headers))
        else
          raise ArgumentError, "Unsupported HTTP method: #{method}"
        end

        # JSON.parse(response.body)
      rescue ActiveResource::UnauthorizedAccess
        Rails.logger.warn("Unauthorized: Refreshing token")
        handle_token_refresh
        retry
      rescue ActiveResource::ResourceNotFound
        { error: "Resource not found" }
      rescue => e
        { error: e.message }
      end
    end

    # Refresh the Authorization token
    def handle_token_refresh
      setup_authorization
    end

  end # end of 'class << self'

  def self.permitted_attrs
    @permitted_attrs ||= instance_methods(false).grep(/=$/).map { |m| m.to_s.chomp('=') }
  end

  def self.find_by(attributes)
    result = where(attributes)
    result.is_a?(Array) ? result.first : result
  end

  def self.fetch_all_records(endpoint, params = {})
    all_results = []
    limit = 50 # Currently GivePUlse only allows to get 50 records
    offset = 0
    total = nil

    loop do
      response = request_api(endpoint, params.merge(limit: limit, offset: offset), method: :get)
      # Rails.logger.debug("Original Response received: #{response}")
      # Check if response is a Hash and contains a code or error
      if response.is_a?(Hash) && response[:error]
        Rails.logger.error("API Error: #{response[:error]}")
        break
      end

      # If response is a Hash with a code key, check the code
      # (Adjust this based on your request_api implementation)
      if response.is_a?(Hash) && response[:code]
        if response[:code].to_i != 200
          Rails.logger.error("Response code: #{response[:code]}, message: #{response[:message]}")
          break
        end
      end
      
      response_body = JSON.parse(response.body)
      # Rails.logger.debug("Json Parse Response body received: #{response_body}")

      total ||= response_body['total'].to_i
      results = response_body['results'] || []

      break if results.empty?

      all_results.concat(results)
      offset += limit

      break if all_results.size >= total
    end

    all_results
  end

end

