class OfferingStatus < ApplicationRecord
  stampable
  belongs_to :offering
  belongs_to :application_status_type
  has_many :offering_status_emails, :dependent => :nullify
  has_many :emails, :class_name => "OfferingStatusEmail"
  acts_as_list column: :sequence

  validates_presence_of :offering
  validates_presence_of :application_status_type

  delegate :description, :to => :application_status_type

  def application_status_name
    application_status_type.name
  end
  
  def application_status_title
    application_status_type.name.titleize
  end
  
  def private_title
    application_status_title
  end

  # for activeadmin breadcrumb title display
  def display_name
    private_title
  end
  
  def <=>(o)
    sequence.to_f <=> o.sequence.to_f rescue 0
  end
  
end
