# Every StudentTranscript seems to have an associated StudentTranscriptMajor; this was the major of the student for the given quarter. (Note there is no documentation on this, so there's no way to be sure).
class StudentTranscriptMajor < StudentInfo
  self.table_name = "transcript_tran_col_major"
  self.primary_keys = :system_key, :tran_yr, :tran_qtr, :index1
  belongs_to :transcript, :class_name => "StudentTranscript", :foreign_key => ["system_key", "tran_yr", "tran_qtr"]
  
  # Returns the Major object associated with this StudentTranscriptMajor. We don't use a true association here because of 
  # the inconsistincies of the data structures of the SDB.
  def major
    Major.where("major_branch = ? AND major_pathway = ? AND major_abbr = ?", tran_branch, tran_pathway, tran_major_abbr).order("major_last_yr DESC, major_last_qtr DESC").first
  end
  
  # Returns the full name of the major, stripped of whitespace.
  def full_name
    major.title rescue major_abbr
  end
  
  def to_s
    full_name
  end
  
  def major_abbr
    tran_major_abbr
  end

  def branch
    tran_branch
  end
  
  def pathway
    tran_pathway
  end

  # Campus code: 0 => Seattle, 1 => Bothell, 2 => Tacoma
  def branch_name
   if branch == 0
     "Seattle Campus"
   elsif branch == 1
     "Bothell Campus"
   elsif branch == 2
     "Tacoma Campus"
   else
     "Unkown"
   end
  end
  
end
