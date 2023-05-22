class Person < ApplicationRecord  
  model_stamper
  belongs_to :department
  belongs_to :institution
  belongs_to :class_standing, :class_name => "ClassStanding", :foreign_key => "class_standing_id"
  before_create :generate_token
  
  has_many :users
  accepts_nested_attributes_for :users
  has_many :application_for_offerings do
    def past
      all.select{|a| a.offering.past? }
    end
    def current
      all.select{|a| a.offering.current? }
    end
    def open
      all.select{|a| a.offering.open? }
    end
    def closed
      all.select{|a| !a.offering.open? }
    end
  end
  has_many :application_mentors     
  
  has_many :committee_members
  has_many :committees, :through => :committee_members
  has_many :contact_histories, -> {order('updated_at DESC')}
  has_many :event_staffs
  has_many :event_staff_shifts, :through => :event_staffs, :source => :shift do
    def for; where(event_staff_position_id: position.id); end
  end
  
  has_many :appointments, :foreign_key => 'staff_person_id' do    
    def today;  where("DATE(start_time) = ?", Time.now.to_date);  end
    def yesterday; where("DATE(start_time) = ?", 1.day.ago.to_date); end
    def tomorrow; where("DATE(start_time) = ?", 1.day.from_now.to_date); end
  end
  
  has_many :service_learning_placements do
    # Limit results to placements that are specifically connected to the supplied object. Object can be a Quarter, a 
    # ServiceLearningPosition, or a ServiceLearningCourse.
    # if unit is nil, we get placements from all units except pipeline
    def for(obj, unit = Unit.find_by_abbreviation("carlson"))
      unit_id = unit.nil? ? [1,9] : unit.id
      if obj.is_a? Quarter        
        includes(:position => {:organization_quarter => :organization}).where(organization_quarters: { quarter_id: obj.id, unit_id: unit_id})      
      else
        includes(:position => {:organization_quarter => :organization}).where(organization_quarters: { unit_id: unit_id}).where(["#{obj.class.name.foreign_key} = ? ", obj]) rescue []        
      end
    end
  end
  
  has_many :pipeline_placements, -> { inclues(:position => {:organization_quarter => :organization}).where(["organization_quarters.unit_id = :unit_id OR service_learning_placements.unit_id = :unit_id ", :unit_id => Unit.find_by_abbreviation("pipeline")])}, :class_name => "ServiceLearningPlacement" do
    # Limit to the passed quarter
    def for(quarter, unit = Unit.find_by_abbreviation("pipeline"))
      if quarter.is_a? Quarter
        includes(:position => {:organization_quarter => :organization}).where(organization_quarters: {quarter_id: quarter.id, unit_id: unit.id}).or(service_learning_placements: {unit_id: unit.id})
        # find(:all, 
        #      :conditions => [" organization_quarters.quarter_id = :quarter_id AND 
        #                        (organization_quarters.unit_id = :unit_id OR
        #                         service_learning_placements.unit_id = :unit_id) ", 
        #                        {:quarter_id => quarter.id, :unit_id => unit.id}],
             
      else
        return nil
      end
    end
  end
      

  has_many :service_learning_self_placements do
  #Object can be a ServiceLearningPosition, or a ServiceLearningCourse.
    def for(obj, quarter)
      where(["#{obj.class.name.foreign_key} = ? AND quarter_id = ?", obj, quarter.id ]) rescue []
    end
  end
  
  has_many :course_extra_enrollees, :dependent => :destroy do
    def for(qtr)
      where(:ts_year => qtr.year, :ts_quarter => qtr.quarter_code_id)      
    end
  end
  has_many :service_learning_course_extra_enrollees, -> {includes(:service_learning_course)}
  has_many :extra_service_learning_courses, 
            :class_name => "ServiceLearningCourse", 
            :through => :service_learning_course_extra_enrollees,
            :source => :service_learning_course

  validates :firstname, presence: true, if: :require_validations?
  validates :lastname,  presence: true, if: :require_validations?
  validates :email, presence: true, email: {mode: :strict, require_fqdn: true}, if: :require_validations?
  validates :address1, presence: true, if: :require_address_validations?
  validates :city, presence: true, if: :require_address_validations?
  validates :state, presence: true, if: :require_address_validations?
  validates :zip, presence: true, if: :require_address_validations?
  validate :student_validations, :if => :require_student_validations?

  scope :non_student, -> { where(type: nil) }

  attr_accessor :require_validations, :require_name_validations, :require_address_validations, :require_student_validations

  # Fullname search with ransack where firstname + lastname in People model
  ransacker :full_name do |parent|
     Arel::Nodes::NamedFunction.new('CONCAT_WS', [Arel::Nodes.build_quoted(' '), parent.table[:firstname], parent.table[:lastname]])
  end

  def require_validations?
    require_validations
  end
  
  def require_name_validations?
    return false if self.is_a?(Student)
    require_name_validations
  end
  
  def require_address_validations?
    return false if self.is_a?(Student)
    require_address_validations
  end
  
  def require_student_validations?
    return false if self.is_a?(Student)
    require_student_validations
  end
  
  def student_validations
    unless self.is_a?(Student)
      errors.add :major_1, "can't be blank" if major_1.blank?
      errors.add :institution_id, "can't be blank" if institution_id.nil?
      errors.add :class_standing_id, "can't be blank" if class_standing_id.nil?
    end
  end
  
  # for activeadmin breadcrumb title display
  def display_name
    "#{fullname}"
  end
  
  def <=>(o)
    lastname_first <=> o.lastname_first
  end
  
  def fullname
    if fullname_unknown?
      email.blank? ? "(Name unknown)" : "#{email}"
    else
      "#{firstname} #{lastname}"
    end
  end
  
  alias_method :identifier_string, :fullname
  
  def fullname_unknown?
    firstname.nil? && lastname.nil?
  end
  
  def formal_fullname
    salutation.blank? ? "#{fullname}" : "#{salutation} #{fullname}"
  end
  
  def lastname_first(formal = true)
    "#{lastname}, #{formal ? formal_firstname(true) : firstname}" # rescue "(name unknown)"
  end
  
  # TODO: fix nickname return without stripping
  def formal_firstname(include_nickname = false)
    include_nickname ? "#{firstname.try(:strip)}#{" (" + nickname.strip + ")" unless nickname.blank?}" : firstname.try(:strip)
  end
  
  def firstname_first(formal = true)
    "#{formal ? formal_firstname(true) : firstname.try(:strip)} #{lastname}"
  end
  
  # Returns this person's nickname, unless the nickname is the exact same as the firstname (in which case, return nil).
  def nickname
    formal_firstname(false).try(:strip) == read_attribute(:nickname).try(:strip) ? nil : read_attribute(:nickname).try(:strip)
  end
  
  # Splits a fullname into firstname and lastname.
  def self.get_first_and_last(n)
    n.split.values_at(0,-1) rescue [nil,nil]
  end
  
  def formal_greeting
    salutation.blank? ? "#{fullname}" : "#{salutation} #{lastname}"
  end
  
  def department_name
      department.nil? ? other_department : department.department_full_name
  end
    
  def generate_token
    write_attribute :token, Base64.encode64(Digest::SHA1.digest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}/#{object_id}"))[0..7]
  end
  
  def phone=(number)
    write_attribute :phone, number.to_s.gsub(/\D/,"")
  end
  
  def fax=(number)
    write_attribute :fax, number.to_s.gsub(/\D/,"")
  end
    
  def phone_formatted
    ActiveSupport::NumberHelper.number_to_phone(read_attribute(:phone))
  end
    
  def fax_formatted
    ActiveSupport::NumberHelper.number_to_phone(fax)
  end

  # Returns a formatted address block for this person, including name. Depending on whether or not this person has a custom address 
  # block defined in the +address_block+ attribute, this method will either construct an address block from the other address details
  # or simply return the custom address block from the database. If this person has a box number defined, then we simply return the 
  # name and box number.
  def address_block(delimiter = "\n", options = {})
    return read_attribute(:address_block) unless read_attribute(:address_block).blank?
    a = "#{formal_fullname}"
    if box_no.blank?
      a << "#{delimiter}#{address1}"
      a << "#{delimiter}#{address2}" unless address2.blank?
      a << "#{delimiter}#{address3}" unless address3.blank?
      a << "#{delimiter}" unless city.blank? || state.blank? || zip.blank?
      a << "#{city}" unless city.blank?
      a << ", " unless city.blank? && state.blank?
      a << "#{state} "
      a << "#{zip}"
    else
      a << "#{delimiter}Box #{box_no}"
    end
    a
  end
  
  # Based on gender, returns a "his" or "her." If gender is not specified, returns "his or her."
  def his_her
    "their"
    # gender.blank? ? "his or her" : gender == "F" ? "her" : "his"
  end
  
  # Based on gender, returns a "he" or "she." If gender is not specified, returns "he or she."
  def he_she
    "they"
    # gender.blank? ? "he or she" : gender == "F" ? "she" : "he"
  end
  
  # Based on gender, returns a "him" or "her." If gender is not specified, returns "him or her."
  def him_her
    "them"
    # gender.blank? ? "him or her" : gender == "F" ? "her" : "him"
  end    
  
  # Returns true if the students has been placed into a ServiceLearningPlacement for a given ServiceLearningCourse.
  def placed_for?(service_learning_course)
    !service_learning_placements.for(service_learning_course).empty?
  end

  # Places this person into the specified position for the specified course. Pass +true+ for the third parameter to also
  # update the date that this person submitted a risk waiver form. By default, this method sends the confirmation email to the student
  # at the end; pass +false+ as the fourth paramater to reverse this behavior.
  def place_into(position, service_learning_course, unit = nil, update_service_learning_risk_paper_date = false, send_confirmation_email = "1")
    ServiceLearningPlacement.transaction do  
      placement = position.placements.open_for_place(service_learning_course) rescue nil
      if placement
        placement.update_attribute :person_id, self.id
        placement.update_attribute :unit_id, unit.nil? ? position.unit_id : unit.id        
        update_attribute :service_learning_risk_placement_id, placement.id 
        update_attribute :service_learning_risk_paper_date, Time.now if update_service_learning_risk_paper_date == "1"
          
        if send_confirmation_email == "1" && position.try(:unit).try(:bothell?)          
          EmailContact.log(self.id, EmailTemplate.find_by_name("bothell service learning registration complete").create_email_to(placement).deliver_now)
        elsif send_confirmation_email == "1"                  
          EmailContact.log(self.id, EmailTemplate.find_by_name("service learning registration complete").create_email_to(placement).deliver_now)
        elsif send_confirmation_email == "2"
          EmailContact.log(self.id, EmailTemplate.find_by_name("pipeline service learning registration complete").create_email_to(placement).deliver_now)
        end      
      end
    end
    true
  end
  
  # Uses the place_into function but adds the ability to create a placement if it should
  def place_into!(position, service_learning_course, unit = nil, update_service_learning_risk_paper_date = false, send_confirmation_email = "1", force = true)
    ServiceLearningPosition.transaction do
      if force
        service_learning_course_id = service_learning_course.nil? ? nil : service_learning_course.id
        position.placements.create(:service_learning_course_id => service_learning_course_id)
        position = position.reload
      end    
      return place_into(position, service_learning_course, unit, update_service_learning_risk_paper_date, send_confirmation_email)
    end
  end

  # Returns an array of this person's majors, based on the "major_n" fields in the person record. Used for non-UW students.
  def majors
    [major_1, major_2, major_3].delete_if{|m| m.blank?}
  end
  
  # Constructs a printable list of majors based on the three "major_n" fields in the person record. Used for non-UW students.
  # The syntax of this method matches that in Student, but because we store major names as text only in the Person record, the
  # +show_full_names+ parameter is ignored.
  def majors_list(show_full_names = false, join_string = ", ", reference_quarter = nil)
    majors.join(join_string)
  end
  
  def class_standing_description(opts = {})
    class_standing.description unless class_standing.nil?
  end
 
  # For non-Students, we don't know, so we pass "unknown"
  def gpa
    "unknown"
  end
  
  # For non-Students, we don't know, so we return +NaN+.
  def gpa
    0.0/0.0
  end
 
  def institution_name
    read_attribute(:institution_name).blank? ? (institution.name unless institution.nil?) : read_attribute(:institution_name)
  end

  def transfer_student?
    false
  end
  
  def washington_state_resident?
    false
  end

  def earned_award?(award_type)
    awards.include?(award_type)
  end
  
  # Retrieves the award_type objects of awards that this student has earned. This is not a normal association because
  # awards earned are stored in the +award_ids+ attribute as space-separated ID values instead of proper DB objects.
  # TODO: Change this to a real association!
  def awards
    return [] if award_ids.nil?
    AwardType.find(award_ids.split)
  end
  
  # Converts the array of award_ids into a space-separated string for storage.
  def award_ids=(ids)
    return nil unless ids.is_a?(Hash)
    self.write_attribute(:award_ids, ids.keys.join(" "))
  end
  
  # Constructs a list of awards based on the "award_ids" field in the person record.
  def awards_list(join_string = ", ")
    return "" if awards.empty?
    awards.collect(&:scholar_title).join(join_string)
  end
  
  # Returns true if this person's contact information was updated since the specified time, according to
  # the +contact_info_updated_at+ attribute of this Person.
  def contact_info_updated_since(t)
    return false if contact_info_updated_at.nil?
    t < contact_info_updated_at
  end

  # Tries to find a person using the information passed to it. If a good match can't be found, we create
  # a new Person using the information passed. The only paramater is the hash of attributes to search and/or
  # create the record with.
  # 
  # Notes:
  # 
  #  * This method ONLY searches non-Students (records with a +type+ equal to +nil+).
  #  * Include :debug => true in the list of attributes to print out progress info.
  #  * E-mail is used as the primary search term.
  #  * If multiple records are found with an email search, we try to find a match on name.
  #  * If multiple records still exist, then use the newest record (based on updated_at).
  #  * If email is not given to search with, we look for an exact firstname/lastname match and return that record
  #     ONLY if there is only a single result. Otherwise, don't take chances and create a new one.
  #  * If nothing can be found, we create a new record using the information passed.
  #  * Validations are skipped when creating a new record, allowing minimal data to still create a record.
  def self.find_or_create_by_best_guess(attrs = {})
    @debug = attrs.delete(:debug) || false
    return nil if attrs.empty?
    
    person = Person.find_by_best_guess(attrs = {})
    return person unless person.nil?
    
    puts "Creating new Person record." if @debug
    Person.create(attrs)
  end
  
  def self.find_by_best_guess(attrs = {})
    return nil if attrs.empty?
    if !attrs[:email].blank?
      puts "Email provided; searching for results." if @debug
      email_results = Person.find_all_by_email_and_type(attrs[:email], nil)
      puts "Found #{email_results.size} email results" if @debug
      if email_results.size == 1
        return email_results.first
      else
        lastname_results = email_results.select{|p| p.lastname == attrs[:lastname] }
        puts "   Found #{lastname_results.size} lastname results" if @debug
        if lastname_results.size == 1
          return lastname_results.first
        elsif lastname_results.size == 0
          puts "   No matching lastnames found" if @debug
        else
          firstname_results = lastname_results.select{|p| p.firstname == attrs[:firstname] }
          puts "      Found #{firstname_results.size} firstname results" if @debug
          if firstname_results.size == 1
            return firstname_results.first
          elsif firstname_results.size == 0
            puts "      No matching firstnames found" if @debug
          else
            puts "Returning most recently updated record." if @debug
            return (firstname_results.sort_by(&:updated_at) rescue firstname_results).last
          end
        end
      end
    else # email was not given, so search for an exact name match and return it only if we find a unique record
      puts "No email provided; searching for exact name match." if @debug
      fullname_results = Person.find_all_by_firstname_and_lastname_and_type(attrs[:firstname], attrs[:lastname], nil)
      puts "   Found #{fullname_results.size} full name results" if @debug
      return fullname_results.first if fullname_results.size == 1
    end
    puts "Could not find any matching records to return." if @debug
    return nil
  end  

  def moa_expiration_date
    if service_learning_moa_date < DateTime.new(service_learning_moa_date.year, 8, 1)
      DateTime.new(service_learning_moa_date.year, 8, 1)
    else
      DateTime.new(service_learning_moa_date.year.next, 8, 1)
    end
  end
  
end