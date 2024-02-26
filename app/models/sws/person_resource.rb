# Person Web Service (PWS): https://ws.admin.washington.edu/identity/swagger/index.html
class PersonResource < WebServiceResult
  
  SWS_VERSION = "v2"

  self.element_path = "identity/#{SWS_VERSION}/person"
  self.cache_lifetime = 1.day

  def self.method_missing(method, *args)
    if method.to_s =~ /find_by_reg_id/
      attribute = :uwRegID    
    elsif method.to_s =~ /find_by_(net_id|uw_netid)/
      attribute = :uwNetID
    elsif method.to_s =~ /find_by_employee_id/
      attribute = :employeeID
    elsif method.to_s =~ /find_by_(student_number|student_no)/
      attribute = :studentID
    else
      super
    end
    self.find_by_attribute(attribute, *args)
  end

  def self.find_by_attribute(attribute, search_term, fetch_record = true)    
    result = self.encapsulate_data(connection.get("#{self.element_path}.json?#{attribute.to_s}=#{search_term.to_s}"))
    # puts "Debug => #{result.inspect}"
    return nil if result.empty? || result['Persons'].empty?
    result_regid = result['Persons'].first['PersonURI']['UWRegID']
    
    fetch_record ? self.find(result_regid) : result_regid
  end


end