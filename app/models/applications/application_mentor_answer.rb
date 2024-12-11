# An ApplationMentor's answer to a specific OfferingMentorQuestion.
class ApplicationMentorAnswer < ApplicationRecord
  stampable
  belongs_to :question, :class_name => "OfferingMentorQuestion", :foreign_key => "offering_mentor_question_id"
  delegate :offering, :to => :question
  belongs_to :application_mentor
  
  validates :offering_mentor_question_id, uniqueness: { scope: :application_mentor_id }

  validates :answer, presence: true, if: ->(a) { !a.skip_validations && a.required? }
  delegate :required?, :to => :question
  
  validates :answer, numericality: true, if: ->(a) { !a.skip_validations && a.must_be_number? }
  delegate :must_be_number?, :to => :question
  
  attr_accessor :skip_validations
  
end
