class ResearchOpportunity < ActiveRecord::Base
  self.per_page = 20
  validates_presence_of :name
  validates_presence_of :email
  validates_format_of   :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_presence_of :title
  validates_presence_of :department
  validates_presence_of :description
  validates_presence_of :requirements
  validates_presence_of :end_date, :message => "(auto-remove date) can't be blank."
  validates_presence_of :research_area1
  validate :end_date_cannot_be_in_the_past
  
  scope :active, -> { where('active = 1 AND (ISNULL(end_date) OR end_date > CURDATE())')}

  def area_name(area_id)
    ResearchArea.find(area_id).name rescue nil
  end 

  def active_status
    active? ? "activated" : "deactivated"
  end
  
  protected 
  
  def end_date_cannot_be_in_the_past
    errors.add(:end_date, "(auto-remove date) can't be in the past") if !end_date.blank? and end_date < Date.today
  end
  
end
