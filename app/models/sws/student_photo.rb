class StudentPhoto < WebServiceResult
  
  SWS_VERSION = "v1"

  self.element_path = "idcard/#{SWS_VERSION}/photo"  
  self.cache_lifetime = 1.month
  
  # Overrite encapsulate_data to use subclass
  def self.encapsulate_data(data)
    data
  end
  
  def [](attribute)
    return nil unless %w(default small medium large).include?(attribute.to_s) || attribute.is_a?(Fixnum)
    image_path(attribute)
  end

  # Alias for #image_path.
  def document(size = nil, force_refresh = false)
    image_path(size, force_refresh)
  end

  # Loads the image and saves it to our server if necessary, then returns the local path.
  # You can specify any of the standard sizes (:default, :small, :medium, :large) or
  # a number to specify the height that you want (i.e., +96+ will give you a 96-pixel tall
  # image).
  def image_path(size = nil, force_refresh = false)
    fetch_and_store_image!(size) if force_refresh || expired?(size)
    file_path(size)
  end

  class << self
    def headers
      { "x-uw-act-as" => 'expo', "Accept" => "image/jpg" }
    end
  end
  
  protected
  
  def fetch_and_store_image!(size)
    suffix = (size.nil? || size.to_s == 'default') ? ".jpg" : "-#{size.to_s}.jpg"
    raw = connection.get(constructed_path(suffix))    
    FileUtils.mkdir_p(File.dirname(file_path(size))) unless File.exists?(File.dirname(file_path(size)))
    File.open(file_path(size), 'wb') {|f| f.write(raw) }
  end
  
  def expired?(size)
    return true unless File.exists?(file_path(size))
    return true if (File.mtime(file_path(size)) < (Time.now - self.class.cache_lifetime))
    false
  end

  def file_path(size = nil)
    filename = (size.nil? || size.to_s == 'default') ? "default" : size.to_s
    file_path = File.join("#{Rails.root}", "tmp", "cache", "web_service_result", "StudentPhoto", @id.to_s, "#{filename}.jpg")
  end
  
end