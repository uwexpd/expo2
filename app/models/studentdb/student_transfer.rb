# Each institution that a student previously attended (and had transfer credits from) has its own StudentTransfer record. Each one has multiple StudentTransferCourse records displayed on a transcript.
class StudentTransfer < StudentInfo
  self.table_name = "sec.sr_transfer"
  self.primary_keys = :system_key, :institution_code
  belongs_to :student_record, :class_name => "StudentRecord", :foreign_key => "system_key"
  has_many :courses, :class_name => "StudentTransferCourse", :foreign_key => ["system_key", "institution_code"]
  belongs_to :institution, :class_name => "Institution", :foreign_key => "institution_code", primary_key: "table_key" # not working and have to use workaround: institution_from_code

  # Workaround to get institution record due to table_key is string and institution_code is an integer
  def institution_from_code
    Institution.find_by_table_key(institution_code)
  end
end