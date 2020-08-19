class OfferingInterviewApplicant < ApplicationRecord
  stampable
  belongs_to :offering_interview
  belongs_to :application_for_offering
  
end
