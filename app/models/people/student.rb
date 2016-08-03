# Models a student in the context of EXPo.  Student records are associated with student_1_v records in the UWSDB.
# 
# Note that actual student information is stored in the studentdb models, which connect to UWSDB.  This guarantees that student information is as up-to-date as possible, because we can automatically retrieve student data on a regular basis.  Student models _only_ exist for students that are in the EXPo database, not for every student in the student database.  This is why methods like +find_or_create_by_student_no+ exist to allow an EXPo Student record to be created any time we reference a student.
class Student < Person
  belongs_to :sdb, :class_name => "StudentRecord", :foreign_key => "system_key"  
  validates :student_no, presence: true
  
  
  SDB_CACHE_VALIDITY_LENGTH = {
     :name     => 1.month,
     :class_standing     => 1.month,
     :gender     => 1.year,
     :email    => 1.week
   }

   # Checks if the SDB-based contact information for this record is out-of-date by comparing the current +sdb_update_at+
   # with the constants SDB_CACHE_VALIDITY_LENGTH. This method is called during any methods that pull student name or 
   # email information.
   def sdb_update(attr_group)
     valid_length = SDB_CACHE_VALIDITY_LENGTH[attr_group]
     self.fetch_sdb_updates if valid_length.nil? || sdb_update_at.nil? || Time.now - sdb_update_at > valid_length
   end
   
   def fetch_sdb_updates
     log_with_color "UWSDB Fetch", "Fetching student data update for Student #{self.id}"
     return false if sdb.nil?
     attrs = { 
       :fullname => sws ? sws.fullname : sdb.fullname,
       :firstname => sws ? sws.firstname : sdb.firstname,
       :lastname => sws ? sws.lastname : sdb.lastname,
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
   
end