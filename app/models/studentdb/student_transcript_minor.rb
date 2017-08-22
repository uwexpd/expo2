# Every StudentTranscript seems to have an associated StudentTranscriptMinor; this was the minor of the student for the given quarter. (Note there is no documentation on this, so there's no way to be sure).
class StudentTranscriptMinor < StudentInfo
  self.table_name = "transcript_tran_minor_group"
  self.primary_keys = :system_key, :tran_yr, :tran_qtr, :index1
  belongs_to :transcript, :class_name => "StudentTranscript", :foreign_key => ["system_key", "tran_yr", "tran_qtr"]
end
