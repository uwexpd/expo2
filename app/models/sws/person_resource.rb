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

  # Fetch FULL by REGID
  def self.find_full(regid)
    raw = connection.get("#{self.element_path}/#{regid}/full.json")
    data = self.encapsulate_data(raw)
    return nil if data.nil? || data.empty?
    self.new(data['Person'] || data)
  end

  # Resolve netid → regid, then fetch FULL
  def self.find_full_by_uw_netid(netid)
    regid = self.find_by_attribute(:uwNetID, netid, false) # returns regid
    return nil unless regid
    find_full(regid)
  end

  class << self
    alias_method :find_full_by_netid, :find_full_by_uw_netid
  end


  # Safely get the underlying attributes hash regardless of where it’s stored.
  def attrs
    if respond_to?(:attributes) && attributes.is_a?(Hash) && !attributes.empty?
      attributes
    elsif instance_variable_defined?(:@attributes) && @attributes.is_a?(Hash)
      @attributes
    elsif instance_variable_defined?(:@id) && @id.is_a?(Hash)
      @id
    else
      {}
    end
  end


  # 1) DisplayName (fallback to PreferredFirstName + PreferredSurname if needed)
  def display_name
    attrs['DisplayName'] ||
      begin
        first = attrs['PreferredFirstName'] || attrs['RegisteredFirstMiddleName']
        last  = attrs['PreferredSurname']   || attrs['RegisteredSurname']
        [first, last].compact.join(' ').presence
      end
  end

  # Convenience accessor for the EmployeePersonAffiliation blob
  def employee_affiliation
    attrs.dig('PersonAffiliations', 'EmployeePersonAffiliation') || {}
  end

  # 2) EmployeePersonAffiliation["HomeDepartment"]
  def employee_home_department
    employee_affiliation['HomeDepartment']
  end

  # 3) EmployeePersonAffiliation["EmployeeWhitePages"]["EmailAddresses"]
  def employee_email_addresses
    employee_affiliation.dig('EmployeeWhitePages', 'EmailAddresses') || []
  end





end