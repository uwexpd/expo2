module Givepulse
  class User  < ActiveResource::Base
    # Set the API base URL (site)
    self.site = 'https://api2.givepulse.com/'

    # auth_string = "Basic bmxIMk1YaWhQRURZY3o0N3ByaXRMcXhDUW03dUtxSGo6ajlVdEFFY084N1Vhb3dMbUlVSkwxeGFhSWQ5N1BTZ3U6am9zaGxpbiU0MHV3LmVkdTpuYW5ha28lMjElMjElMjE0"
    # auth_token = Base64.strict_encode64(auth_string)

    # Add any headers needed for authentication or other purposes
    self.headers['Authorization'] = "Bearer Basic bmxIMk1YaWhQRURZY3o0N3ByaXRMcXhDUW03dUtxSGo6ajlVdEFFY084N1Vhb3dMbUlVSkwxeGFhSWQ5N1BTZ3U6am9zaGxpbiU0MHV3LmVkdTpuYW5ha28lMjElMjElMjE0"
    self.headers['Content-Type'] = 'application/json'    

    # Fetch all users with a group_id parameter
    def self.fetch_all_users(group_id = 1246545)
      # Define the query parameters
      params = { group_id: group_id }

      # Perform the GET request with the group_id parameter
      get('/users', params: params)  # ActiveResource will automatically append this to the URL
    end
  end
end
