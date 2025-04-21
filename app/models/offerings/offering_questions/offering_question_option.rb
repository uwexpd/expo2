class OfferingQuestionOption < ApplicationRecord
  stampable
  belongs_to :offering_question
  belongs_to :associate_question, class_name: 'OfferingQuestion', foreign_key: 'associate_question_id', optional: true
  belongs_to :next_page, class_name: 'OfferingPage', foreign_key: 'next_page_id', optional: true

  validates_presence_of :offering_question_id, :title
  
  def value
    read_attribute(:value).blank? ? title : read_attribute(:value)
  end
  
  # def associate?
  #   return !associate_question_id.nil?
  # end
  
  # def associate_question
  #   offering_question.find(associate_quesiton_id) if associate?
  # end
  
end
