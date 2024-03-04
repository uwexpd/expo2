class UwWebServiceConnection < ActiveResource::Connection

  cattr_accessor :debug
  attr_accessor :caller_class

  # Execute a GET request.
  # Used to get (find) resources.
  def get(path, headers = {})
    begin
      body = nil
      time = Benchmark::realtime { body = request(:get, path).body }
      sws_log "GET #{path}", time
      body
      # Process the successful response
    rescue ActiveResource::Redirection => e
      # Handle redirection (3xx status code)
      Rails.logger.error "Redirection error: #{e.response.code} - #{e.response.message}"
    rescue ActiveResource::ResourceNotFound => e
      # Handle resource not found (404 status code)
      Rails.logger.error "Resource not found error: #{e.response.code} - #{e.response.message}"
    rescue ActiveResource::ServerError => e
      # Handle server errors (5xx status codes)
      Rails.logger.error "Server error: #{e.response.code} - #{e.response.message}"
    rescue ActiveResource::ClientError => e
      # Handle other client errors (4xx status codes)
      Rails.logger.error "Client error: #{e.response.code} - #{e.response.message}"
    rescue => e
      # Handle other exceptions
      Rails.logger.error "Unexpected error: #{e.message}"
      nil
    end
  end

  private

    def http
      configure_http(new_http_with_debug)
    end

    def new_http_with_debug
      h = new_http
      h.set_debug_output(debug == true ? $stderr : nil)
      h
    end
    
    def sws_log(msg, time = nil)
      caller_class_s = caller_class.to_s == "Class" ? self.class.to_s : (caller_class.to_s || self.class.to_s)
      message = "  \e[4;33;1m#{caller_class_s} Fetch"
      message << " (#{'%.1f' % (time*1000)}ms)" if time
      message << "\e[0m   #{msg}"
      Rails.logger.info message
    end
  
end