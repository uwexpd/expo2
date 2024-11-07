module GivePulse
  class GivePulseApi

      # self.site = 'https://api2.givepulse.com/users'
      # self.headers['Content-Type'] = 'application/json'
      
      # Custom method to set token
      def self.get_token
        # consumer_key = 'nlH2MXihPEDYcz47pritLqxCQm7uKqHj'
        # consumer_secret = 'j9UtAEcO87UaowLmIUJL1xaaId97PSgu'
        # email = 'expohelp@uw.edu'
        # password = 'iloveEXPO'
        # auth_string = "#{consumer_key}:#{consumer_secret}:#{email}:#{password}"
        # auth_string = "Basic bmxIMk1YaWhQRURZY3o0N3ByaXRMcXhDUW03dUtxSGo6ajlVdEFFY084N1Vhb3dMbUlVSkwxeGFhSWQ5N1BTZ3U6am9zaGxpbiU0MHV3LmVkdTphcGljYWxsMTEwNg=="
        # Base64 encode the auth string
        # auth_token = Base64.strict_encode64(auth_string)
        
        # response = ActiveResource::Connection.new(self.site).post(
        #   '/auth',
        #   nil,
        #   { 'Authorization' => "Basic #{auth_token}" }
        # )
        # JSON.parse(response.body)["token"]      
      end

      def self.fetch_data
      # Initialize the connection to the API
      connection = ActiveResource::Connection.new("https://api2.givepulse.com/users")

      # Set the request headers (e.g., for authentication)
      headers = {
        'Authorization' => 'Bearer your_token_here',
        'Content-Type' => 'application/json'
      }

      # Set the query parameters
      params = {
        group_id: '1246545'
      }

      # Send the GET request to the API
      response = connection.get('/endpoint', params, headers)

      # Handle the response
      if response.code == 200
        # Parse the response and return the data (assumed to be JSON)
        JSON.parse(response.body)
      else
        # Log the error or handle it as needed
        Rails.logger.error("API request failed with code: #{response.code} - #{response.body}")
        nil
      end
    end

  end
end