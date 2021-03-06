class OfferingMentorType < ApplicationRecord
  stampable
  belongs_to :application_mentor_type
  belongs_to :offering
  
  delegate :title, :to => :application_mentor_type
end
