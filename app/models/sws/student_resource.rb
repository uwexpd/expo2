require 'capitalize_names'
# UWSWS => Person Search Resource V5, refer to https://wiki.cac.washington.edu/display/SWS/Person+Search+Resource+V5
class StudentResource < WebServiceResult
  
  SWS_VERSION = "v5"

  self.element_path = "student/#{SWS_VERSION}/person"  
  self.cache_lifetime = 1.hour
  
  def self.method_missing(method, *args)
    if method.to_s =~ /find_by_system_key/
      attribute = :student_system_key
    elsif method.to_s =~ /find_by_reg_id/      
      return StudentResource.find(args)
    elsif method.to_s =~ /find_by_(net_id|uw_netid)/
      attribute = :net_id
    elsif method.to_s =~ /find_by_(student_number|student_no)/
      attribute = :student_number
    else
      super
    end
    self.find_by_attribute(attribute, *args)
  end

  # Finds a Student by any attribute or nil if no record was found.
  # By default this will return a StudentResource object, but you can pass +false+ for the +fetch_record+
  # parameter and you'll just get the reg_id for the student.  
  def self.find_by_attribute(attribute, search_term, fetch_record = true)    
    result = self.encapsulate_data(connection.get("#{self.element_path}.json?#{attribute.to_s}=#{search_term.to_s}"))    
    #result_elements = result.css("Person RegID") # this is for parsing xml 
    return nil if result.empty?
    result_regid = result['Persons'].first['RegID']
    
    fetch_record ? self.find(result_regid) : result_regid
  end

  def photo
    @photo ||= StudentPhoto.new(@id)
  end
    
  def lastname
    #self.LastName.try(:titleize)
    CapitalizeNames.capitalize(self.LastName) rescue self.LastName.try(:titleize)
  end
  
  def firstname
    #self.FirstName.try(:titleize)
    CapitalizeNames.capitalize(self.FirstName) rescue self.FirstName.try(:titleize)
  end
  
  def fullname
    lastname + ", " + firstname
  end
  
  def legalname
    CapitalizeNames.capitalize(self.RegisteredName) rescue self.RegisteredName
  end
    
end