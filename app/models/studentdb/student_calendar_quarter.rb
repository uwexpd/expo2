class StudentCalendarQuarter < StudentInfo
  self.table_name = "sys_tbl_39_calendar"
  self.primary_keys = :table_key
  
  def quarter
    regexp = /\d(\d{4})(\d)/
    Quarter.find_easily(table_key[regexp,2], table_key[regexp,1])
  end
  
  def include?(date)
    date >= first_day && date < last_day_classes
  end
  
  # Returns the quarter where the specified date falls. Returns nil if classes aren't in session at that time.
  def self.find_by_date(qdate)
    self.where(":qdate >= first_day AND :qdate < last_day_classes", qdate: qdate.to_s(:db)).limit(1).first
  end
  
end