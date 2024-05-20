=begin rdoc
This is the parent class for result objects that come from the UW Web services (Student web service, idCard service, etc.). It requires that you define a primary_key to be used to fetch records from the web services, and then caches the resulting xhtml document for use later. Then you can access attributes just like a normal ActiveResource object. (Note that we aren't using ActiveResource here because UW web services only provide xhtml formatted data and ActiveResource can't properly parse it.)

Update: Changed to receive XML formatted data from SWS at 12-23-2014 since SWS v5 is no longer support xhtml.
Update: Changed to receive Json data as default at 08-16-2017

== Class Attributes
These class attributes should be defined in sub-classes.

* :site::           Override the base site URI. By default, we pull this value from web_serivces.yml depending 
                    on the current rails environment.
* :element_path::   The path for this specific resource. e.g., "student/v4/person"
* :timeout::        The number of seconds to wait for the service to respond. Default is 5 seconds.
* :cache_lifetime:: The number of seconds to wait before requerying the web service for a record. Default is 1 hour.
* :primary_key::    The attribute name to use as the primary key. This is used in instantiating the record.

=end
class WebServiceResult

  # Specifies that aliases that can be used for certain attributes. This helps with the integration of
  # existing EXPO components. For instance, UW web services use "student_name" instead of "fullname".
  # Specifying +{ :student_name => [:fullname] }+ for this hash allows you to search using both.
  # You can (and should) override this in your subclasses.
  # 
  # The format of the hash is as follows:
  # 
  # * keys:     attribute names from the web service (as a String or Symbol)
  # * values:   an array of possible alias names (as Strings or Symbols)
  ATTRIBUTE_ALIASES = {}

  # Creates a new instance of this WebServiceResult.
  def initialize(primary_key)
    @id = primary_key
    document
    self
  end

  # Same as calling WebServiceResult.new(primary_id). Essentially the same as ActiveRecord.find_by_id.
  def self.find(primary_key)
    self.new(primary_key)
  end

  # Returns an encapsulated object of Json data returned by the service. Also manages the
  # cache and requeries the service if needed. Caches of the raw json are stored in
  # Rails.root/tmp/cache/web_service_result/<class_name>/<primary_key><extension>
  def document(options = {})
    cache = FileStoreWithExpiration.new("tmp/cache/web_service_result/#{self.class.to_s}")
    options[:extension] = '.json'
    cache_key = options[:extension] ? "#{@id.to_s}#{options[:extension]}" : @id.to_s
    @raw = cache.fetch(cache_key, {:expires_in => self.class.cache_lifetime}.merge(options)) do
      connection.get(constructed_path(options[:extension]))
    end  
    self.class.encapsulate_data(@raw)
  end
  
  # Constructs the actual path that will be sent to the service.
  def constructed_path(extension = nil)
    "#{self.class.element_path}/#{@id}#{extension}"
  end
  
  # Overrides #method_missing so that you can access attributes as method call. Uses the +[]+ method to facilitate.
  # If +[]+ returns nil, then +super+ is called and a normal NoMethodError is raised.
  def method_missing(method, *args)
    # puts "Missing method: #{method.to_s}"
    self[method] || super
  end
  
=begin :nodoc:
  # Do we need to define respond_to?
  # def respond_to?(method, include_private = false)    
  # end
=end
  
  # Tries to look up the specified attribute in the returned Json data. 
  # You can also assign attribute aliases in your subclasses by populating the ATTRIBUTE_ALIASES hash. 
  # If no element is found using the base attribute or any aliases, or if an array of 
  # elements bigger than one element is found, this method returns nil. 
  # 
  # Note that no type-casting is performed here.
  def [](attribute)
    matching_aliases = self.class::ATTRIBUTE_ALIASES.collect{|k,v| k unless v.select{|a| a.to_s == attribute.to_s}.empty?}.compact
    aliases = ([attribute] + matching_aliases).flatten.compact
    element = []
    for a in aliases
      # For XML => document.css("Person #{a}") # For SWS V4 -> element = document.xpath("//div/span[@class='#{a.to_s}']")
      element = document["#{a}"]
      
      break unless element.empty? || element.size > 1
    end
    return nil if element.empty?
    element
  end

  class << self

    # Gets the URI of the REST resources to map for this class.
    def site
      @site || "https://#{config_options[:host]}"
    end

    # Sets the URI of the REST resources to map for this class to the value in the +site+ argument.
    # If you pass a full URI here (including "http:" then we use the full path. Otherwise, this
    # method constructs a site URI based on the :host value in the web_services.yml config file.)
    def site=(site)
      @connection = nil
      if site.nil?
        @site = nil
      else
        if site.is_a?(URI)
          @site = site.dup
        else
          @site = site.include?("http") ? site : "https://#{config_options[:host]}"
        end
      end
    end

    # Sets the base path that should be used for looking up an individual record.
    def element_path=(element_path)
      @element_path = element_path
    end
    
    # Gets the base path that should be used for looking up an individual record.
    def element_path
      @element_path = "/" + @element_path if @element_path.is_a?(String) && @element_path.first != "/"
      @element_path
    end    

    # Sets the number of seconds after which requests to the REST API should time out.
    def timeout=(timeout)
      @timeout = timeout
    end
    
    # Gets the number of seconds after which requests to the REST API should time out.
    def timeout
      @timeout || 5
    end
  
    # Sets the number of seconds that web service responses should be cached.
    def cache_lifetime=(cache_lifetime)
      @cache_lifetime = cache_lifetime
    end
    
    # Gets the number of seconds that web service responses should be cached.
    def cache_lifetime
      @cache_lifetime || 1.hour
    end
    
    # Sets the attribute name to use as this object's "primary key".
    def primary_key=(primary_key)
      @primary_key = primary_key
    end
    
    # Gets the attribute name to use as this object's "primary key".
    def primary_key
      @primary_key || :reg_id
    end

    # An instance of UwWebServiceConnection that is the base \connection to the remote service.
    # The +refresh+ parameter toggles whether or not the \connection is refreshed at every request
    # or not (defaults to <tt>false</tt>).
    def connection(refresh = false)
      if !@connection || refresh        
        @connection = UwWebServiceConnection.new(site) if refresh || @connection.nil?
        @connection.timeout = timeout if timeout
        @connection.ssl_options = ssl_options
        @connection.caller_class = self
        @connection        
      else
        @connection
      end
    end
  
    # Attaches our cert, key, and CA file based on the config options in web_services.yml.
    def ssl_options
      check_cert_paths!
      @ssl_options ||= {
        :cert         => OpenSSL::X509::Certificate.new(File.open("#{Rails.root}/config/certs/#{config_options[:cert]}")),
        :key          => OpenSSL::PKey::RSA.new(File.open("#{Rails.root}/config/certs/#{config_options[:key]}")),
        # :ca_file      => "#{Rails.root}/config/certs/#{config_options[:ca_file]}",
        :verify_mode  => OpenSSL::SSL::VERIFY_PEER
      }
    end
  
    # All configuration options are stored in Rails.root/config/web_services.yml. This allows us to use different
    # hosts, certs, etc. in different Rails environments.
    def config_options
      config_file_path = "#{Rails.root}/config/web_services.yml"
      @config_options ||= YAML::load(ERB.new((IO.read(config_file_path))).result)[(Rails.env)].symbolize_keys
    end
    
    # def headers
    #       { "x-uw-act-as" => 'expo', "Accept" => "application/xml" }
    #     end
  
  end

  def connection(refresh = false)
    self.class.connection(refresh)
  end  

  protected

  def sws_log(msg, time = nil)
    message = "  \e[4;33;1m#{self.class.to_s} Fetch"
    message << " (#{'%.1f' % (time*1000)}ms)" if time
    message << "\e[0m   #{msg}"
    RAILS_DEFAULT_LOGGER.info message
  end

  # Encapsulates the raw data from the service into a Nokogiri::XML object. Override in subclasses to do something else. 
  # Update: Changed to parse JSON
  def self.encapsulate_data(raw_data)
    return nil if raw_data.nil? || (raw_data.respond_to?(:empty?) && raw_data.empty?)
    raw_data = clean raw_data
    JSON.parse raw_data
    #Nokogiri::XML(raw_data)
  end

  # Raises an error if the cert, key, or CA file does not exist.
  def self.check_cert_paths!
    raise ActiveResource::SSLError, "Could not find cert file" unless File.exist?("#{Rails.root}/config/certs/#{config_options[:cert]}")
    raise ActiveResource::SSLError, "Could not find key file" unless File.exist?("#{Rails.root}/config/certs/#{config_options[:key]}")
    raise ActiveResource::SSLError, "Could not find CA file" unless File.exist?("#{Rails.root}/config/certs/#{config_options[:ca_file]}")
  end
  
  def self.clean_bools(raw_data)
      raw_data.gsub('"false"', "false")
      raw_data.gsub('"true"', "true")
    end

  def self.clean_spaces(raw_data)
      raw_data.gsub!(/(\\?"|)((?:.(?!\1))+.)(?:\1)/) do |match|
        match.gsub(/^(\\?")\s+|\s+(\\?")$/, "\\1\\2").strip
      end
  end

  def self.clean(raw_data)
      raw_data = clean_spaces raw_data
      raw_data = clean_bools raw_data
  end

end