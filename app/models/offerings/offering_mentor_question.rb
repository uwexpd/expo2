# Mentors can be asked questions when they submit their letters of support. This model defines one of those questions to ask.
# See ApplicationMentorAnswer.
class OfferingMentorQuestion < ApplicationRecord
  stampable
  belongs_to :offering
  
end
