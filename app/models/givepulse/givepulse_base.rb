class GivepulseBase < ActiveResource::Base
  # [PROD] self.site = 'https://api2.givepulse.com'
  # DEV
  # self.site = 'https://api2-dev.givepulse.com' 
  # self.headers['Content-Type'] = 'application/json'
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
    def setup_authorization
      if Rails.env.production?
        env_token = ENV['GIVEPULSE_PRO_TOKEN']
      else
        env_token = ENV['GIVEPULSE_BASIC_TOKEN']
      end
      basic_token = env_token || raise('GIVEPULSE TOKEN is not set!')
      connection = ActiveResource::Connection.new(site)

      # Fetch the Bearer token
      auth_response = connection.post(
        '/auth',
        nil,
        { "Authorization" => "Basic #{basic_token}", "Content-Type" => "application/json" }
      )

      # Rails.logger.debug "DEBUG auth_response => #{auth_response.response.code} | #{auth_response.body}"

      if auth_response&.response&.code.to_i == 200 && auth_response&.body.present?
        token = JSON.parse(auth_response.body)['token']
        raise 'Token missing in authorization response' if token.blank?

        givepulse_headers['Authorization'] = "Bearer #{token}"
        # Rails.logger.info('Authorization token successfully retrieved.')
      else
        Rails.logger.error("Authorization failed: #{auth_response.response.message}")
        raise 'Authorization failed: Invalid response from /auth endpoint'
      end

    end

    # Make API GET requests with automatic token refresh
    def make_request(path, query_params = {})
      begin
        # Append query parameters to the path
        full_path = query_params.present? ? "#{path}?#{query_params.to_query}" : path
        
        connection = ActiveResource::Connection.new(site)
        response = connection.get(full_path, headers) # Pass only path and headers          
        # JSON.parse(response.body)
      rescue ActiveResource::UnauthorizedAccess => e
        # Handle token refresh on 401 Unauthorized
        Rails.logger.warn("Unauthorized: Refreshing token")
        handle_token_refresh
        retry
      rescue ActiveResource::ResourceNotFound
        { error: "Resource not found" }
      rescue => e
        { error: e.message }
      end
    end

    # Make API POST requests with automatic token refresh
    def make_post_request(path, body_params = {}, custom_headers = {})
      begin
        connection = ActiveResource::Connection.new(site)
        response = connection.post(
          path,
          body_params.to_json,
          headers.merge(custom_headers)
        )
        # JSON.parse(response.body)
      rescue ActiveResource::UnauthorizedAccess => e
        Rails.logger.warn("Unauthorized: Refreshing token")
        handle_token_refresh
        retry
      rescue ActiveResource::ResourceNotFound
        { error: "Resource not found" }
      rescue => e
        { error: e.message }
      end
    end

    # Make API requests with support for GET, POST, PUT, and DELETE
    def request_api(path, params = {}, method: :get, custom_headers: {})
      begin
        connection = ActiveResource::Connection.new(site)
      
        full_path = params.present? && [:get, :delete].include?(method) ? "#{path}?#{params.to_query}" : path
        # Debugging: Log the method, full_path, and params (if any)
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

    # Temporarily use a different site (and force new auth token)
    def with_site(temp_site)
      old_site = @site
      old_headers = @givepulse_headers.dup

      self.site = temp_site
      @givepulse_headers = { 'Content-Type' => 'application/json' } # reset headers to force re-auth

      setup_authorization

      yield
    ensure
      self.site = old_site
      @givepulse_headers = old_headers
    end

  end # end of 'class << self'

  def self.permitted_attrs
    @permitted_attrs ||= instance_methods(false).grep(/=$/).map { |m| m.to_s.chomp('=') }
  end

  def self.find_by(attributes)
    result = where(attributes)
    result.is_a?(Array) ? result.first : result
  end

end

