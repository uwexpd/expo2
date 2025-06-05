# class GivepulseAPI
#   include HTTParty
#   base_uri 'https://api2.givepulse.com'
  
#   def initialize
#     basic_token = ENV['GIVEPULSE_BASIC_TOKEN'] || raise('GIVEPULSE_BASIC_TOKEN is not set!')    
#     @headers = {      
#       "Authorization" => "Basic #{basic_token}",
#       "Content-Type" => "application/json"
#     }
#   end

#   def get_auth
#     response = self.class.get("/auth", headers: @headers)
#     token = get_token(response)
#     @api_headers = { 
#       "Authorization" => "Bearer #{token}",
#     }
#   end

#   # https://api2.givepulse.com/users?group_id=000&query=Tom" 
#   # user_id = 6744494 for josh
#   def get_user(id)
#     response = self.class.get("/users?group_id=1246545&user_id=#{id}", headers: @api_headers)
#     handle_response(response)
#   end

#   def get_all_users
#     response = self.class.get("/users?group_id=1246545", headers: @api_headers)
#     handle_response(response)
#   end

#   private

#   def get_token(response)
#     if response.success?
#       token = response['token']        
#     else
#       handle_error(response)
#     end      
#   end

#   def handle_response(response)      
#     case response.code
#     when 200
#       JSON.parse(response.body)
#     when 404
#       { error: "Resource not found" }
#     else
#       { error: "An error occurred", status: response.code, body: response.body }
#     end
#   end
# end

