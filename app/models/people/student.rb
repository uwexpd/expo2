# Models a student in the context of EXPo.  Student records are associated with student_1_v records in the UWSDB.
# 
# Note that actual student information is stored in the studentdb models, which connect to UWSDB.  This guarantees that student information is as up-to-date as possible, because we can automatically retrieve student data on a regular basis.  Student models _only_ exist for students that are in the EXPo database, not for every student in the student database.  This is why methods like +find_or_create_by_student_no+ exist to allow an EXPo Student record to be created any time we reference a student.
class Student < Person
  belongs_to :sdb, :class_name => "StudentRecord", :foreign_key => "system_key"  
  validates :student_no, presence: true
  
  attr_accessor :electronic_signature
  
  delegate :class_standing_description, :raw_gpa, :gpa, :institution_name, :majors_list, :minors_list, :minors, :majors, :age, :transfer_student?, :washington_state_resident?, :to => :sdb
  
  SDB_CACHE_VALIDITY_LENGTH = {
     :name     => 1.month,
     :class_standing  => 1.month,
     :gender     => 1.year,
     :email    => 1.week
   }

   # Checks if the SDB-based contact information for this record is out-of-date by comparing the current +sdb_update_at+
   # with the constants SDB_CACHE_VALIDITY_LENGTH. This method is called during any methods that pull student name or 
   # email information.
   def sdb_update(attr_group)
     valid_length = SDB_CACHE_VALIDITY_LENGTH[attr_group]
     # self.fetch_sdb_updates if valid_length.nil? || sdb_update_at.nil? || Time.now - sdb_update_at > valid_length
   end
   
   def fetch_sdb_updates
     log_with_color "UWSDB Fetch", "Fetching student data update for Student #{self.id}"
     return false if sdb.nil?
     attrs = { 
       :fullname => sws ? (sws.fullname rescue sdb.fullname) : sdb.fullname,
       :firstname => sws ? (sws.firstname rescue sdb.firstname) : sdb.firstname,
       :lastname => sws ? (sws.lastname rescue sdb.lastname) : sdb.lastname,
       :email => sdb.email,
 	     :gender => sdb.s1_gender,
 	     :class_standing_id => sdb.class_standing,
       :sdb_update_at => Time.now 
     }
     update_attributes!(attrs)
   end   
   
   def sws
     @sws ||= StudentResource.find_by_system_key(system_key, true)
   end
   
   def reg_id
    if read_attribute(:reg_id).blank?
      @reg_id ||= StudentResource.find_by_system_key(system_key, false)
      update_attribute(:reg_id, @reg_id)
    else
      @reg_id ||= read_attribute(:reg_id)
    end
    @reg_id
   end

   def firstname
     self.sdb_update(:name)
     nickname.blank? ? read_attribute(:firstname) : nickname
   end


   def formal_firstname(include_nickname = false)
     self.sdb_update(:name)
     include_nickname ? "#{read_attribute(:firstname)}#{" (" + nickname + ")" unless nickname.blank?}" : read_attribute(:firstname)
   end

   def firstname_first(formal = true)
     "#{formal ? formal_firstname(true) : read_attribute(:firstname)} #{lastname}"
   end
   
   def lastname
     self.sdb_update(:name)
     read_attribute(:lastname)
   end

   def fullname
     self.sdb_update(:name)
     nickname.blank? ? read_attribute(:fullname) : read_attribute(:fullname) + " (#{nickname})" rescue "(no student record found)"
   end

   def gender
 	  self.sdb_update(:gender)
     read_attribute(:gender)
   end

   def email
     self.sdb_update(:email)
     read_attribute(:email)
   end

   def student_no
     sdb.nil? ? read_attribute('student_no').to_s.rjust(7,'0') : sdb.student_no.to_s.rjust(7,'0')
   end
   
   def current_credits(quarter = Quarter.current_quarter)
    return 0 if sdb.registrations.size < 1
    sr = sdb.registrations.find_by_regis_yr_and_regis_qtr(quarter.year, quarter.quarter_code_id)
    sr.nil? ? 0 : sr.current_credits
  end
  
  def full_time?(quarter = Quarter.current_quarter)
    current_credits(quarter) >= Rails.configuration.constants['credits_required_for_full_time']
  end

  # Returns true if this student is an undergraduate at the University. A student is considered undergraduate if his or her
  # +class_standing+ is <= 5.
  def undergrad?
    sdb.class_standing <= 5
  end
  
  def class_standing_id
  self.sdb_update(:class_standing)
  read_attribute(:class_standing_id)
  end
  
   # @alias for find_or_create_by_student_no
   def self.find_by_student_no(student_no)
     find_or_create_by_student_no(student_no)
   end

   # Find a student by student number and also create a Student record for that student if needed.
   # - Returns a Student object or nil if search fails
   def self.find_or_create_by_student_no(student_no)
     sr = StudentRecord.find_by_student_no(student_no)
     return nil if sr.blank?
     s = Student.find_by_system_key(sr.system_key)
     if s.blank?
       Student.create(:system_key => sr.system_key, :student_no => sr.student_no)
     else
       s
     end
   end
   
   # @alias for find_or_create_by_uw_netid
    def self.find_by_uw_netid(uw_netid)
      find_or_create_by_uw_netid(uw_netid)
    end

    # Find a student by uw_netid and also create a Student record for that student if needed.
    # - Returns a Student object or nil if search fails
    def self.find_or_create_by_uw_netid(uw_netid)
      sr = StudentRecord.find_by_uw_netid(uw_netid)
      return nil if sr.blank?
      s = Student.find_by_system_key(sr.system_key)
      if s.blank?
        Student.create(:system_key => sr.system_key, :student_no => sr.student_no)
      else
        s
      end
    end
    
    
end