class Quarter < ActiveRecord::Base
  #include Comparable
  stampable
  
  belongs_to :quarter_code
  validates_presence_of :quarter_code, :year, :first_day
  
  default_scope { order('year, quarter_code_id') }
  
  # Returns the quarter abbreviation in the form of "QQQYYYY" (e.g., "AUT2009").
  def abbrev
    "#{quarter_code.abbreviation}#{year}"
  end

  # Searches for Quarters using the quarter abbreviation in the form of "QQQYYYY". Pass an array of abbreviations to find multiple.
  def self.find_by_abbrev(a)
    return nil if a.blank?
    return a.collect{|i| Quarter.find_by_abbrev(i)} if a.is_a?(Array)
    qc = QuarterCode.find_by_abbreviation a[0,3]
    Quarter.find_easily qc, a[3,4]
  end
  
  def title
    quarter_code.name + " " + year.to_s
  end
  
  def self.current_and_future_quarters(limit = nil, current_qtr = nil)
    first_day_cmp = !current_qtr.is_a?(Quarter) ? Time.now : current_qtr.first_day
    Quarter.find(:all, :conditions => [ "first_day >= ?", first_day_cmp ], :limit => limit).sort
  end
  
  def self.future_quarters(limit = nil, current_qtr = nil)
    first_day_cmp = !current_qtr.is_a?(Quarter) ? Time.now : current_qtr.first_day
    Quarter.find(:all, :conditions => [ "first_day >= ?", first_day_cmp ], :limit => limit).sort
  end

  # Returns an array of past quarters going back for as many quarters as requested (defaults to 10 quarters), excluding the current quarter.
  def self.past_quarters(limit = 10)
    past_quarters = []
    q = Quarter.current_quarter.prev
    for i in 1..limit
      past_quarters << q
      q = q.prev
    end
    past_quarters
  end

  # Returns the current Quarter, based on quarter start dates.
  def self.current_quarter
    @current_quarter ||= Quarter.where("first_day < ?", Time.now).order("first_day DESC").first
  end
  
  # Returns true if this quarter is the current_quarter.
  def current_quarter?
    self == Quarter.current_quarter
  end

  def <=>(o)
    year_compare = self.year <=> o.year rescue 0
    return year_compare unless year_compare == 0
    qtr_code_compare = self.quarter_code_id <=> o.quarter_code_id rescue 0
    return qtr_code_compare
  end
  
  # Determines the next Quarter in the calendar
  def next
    next_qtr_code = quarter_code_id == 4 ? 1 : quarter_code_id + 1
    next_year = quarter_code_id == 4 ? year + 1 : year
    Quarter.find_easily(next_qtr_code, next_year)
  end
  
  # Determines the previous Quarter in the calendar
  def prev
    prev_qtr_code = quarter_code_id == 1 ? 4 : quarter_code_id - 1
    prev_year = quarter_code_id == 1 ? year - 1 : year
    Quarter.find_easily(prev_qtr_code, prev_year)
  end
  
  # Finds a Quarter object by quarter_code and year. Automatically creates a new Quarter record if it can't be found.
  def self.find_easily(quarter_code, year)
    q = Quarter.find_by_quarter_code_id_and_year(quarter_code, year)
    q ||= Quarter.create(:quarter_code_id => quarter_code, :year => year, :first_day => guess_first_day(quarter_code, year))
    q
  end
  
  def include?(date)
    date >= start_date && date < self.next.date
  end

  # Returns the academic year of this quarter, which is returned as a string like "2008-2009." For purposes of this method,
  # Summer is the first quarter of the academic year. So Summer 2008 will return "2008-2009" and Spring 2008 will return "2007-2008".
  def academic_year
    academic_year = case quarter_code_id
    when 1
      "#{year-1}-#{year}"
    when 2
      "#{year-1}-#{year}"
    when 3
      "#{year}-#{year+1}"
    when 4
      "#{year}-#{year+1}"
    end
    academic_year
  end

  # Returns the quarter where the specified date falls by calling the same method on StudentCalendarQuarter. Returns the
  # Quarter object instead of a StudentCalendarQuarter object.
  def self.find_by_date(qdate)
    scq = StudentCalendarQuarter.find_by_date(qdate) 
    scq.quarter rescue nil
  end

  protected
  
  def self.guess_first_day(quarter_code, year)
    first_day = case quarter_code
    when 1
      "#{year}-01-01"
    when 2
      "#{year}-04-01"
    when 3
      "#{year}-06-01"
    when 4
      "#{year}-10-01"
    end
    first_day
  end
  
end