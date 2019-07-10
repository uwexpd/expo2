class ResearchOpportunity < ActiveRecord::Base
  self.per_page = 20
  belongs_to :submitted_person, :class_name => "Person", :foreign_key => "submitted_person_id"

  validates_presence_of :name, :title, :email, :department, :description, :requirements, :research_area1
  validates_format_of   :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i  
  validates_presence_of :end_date, :message => "(auto-remove date) can't be blank."
  validate :end_date_cannot_be_in_the_past
  
  scope :active, -> { where('active = 1 AND (ISNULL(end_date) OR end_date > CURDATE())')}

  def area_name(area_id)
    ResearchArea.find(area_id).name rescue nil
  end 

  def active_status
    active? ? "activated" : "deactivated"
  end
  
  private 
  
  def end_date_cannot_be_in_the_past
    errors.add(:end_date, "(auto-remove date) can't be in the past") if !end_date.blank? and end_date < Date.today
  end
  
end
