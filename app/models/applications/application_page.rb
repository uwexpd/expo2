class ApplicationPage < ApplicationRecord
  stampable
  belongs_to :application_for_offering
  belongs_to :offering_page
  
  attr_accessor :ordering, :validation_configuration_errors
  
  delegate :title, :hide_in_admin_view?, :hide_in_reviewer_view?, :to => :offering_page
  
  def ordering
    offering_page.ordering
  end

  def complete?
    return true if complete    
  end

  def passes_validations?
    errors.clear
    self.validation_configuration_errors = []

    offering_page.questions.each do |question|
      question.add_errors(self)
    rescue StandardError => e
      exception_message = e.message.to_s.sub(/\s+for\s+#<.*\z/, "")
      message = "This page has a configuration error: #{exception_message}"
      validation_configuration_errors << message
      errors.add(:base, message)
    end

    errors.empty?
  end

  def next
    self.application_for_offering.visible_pages
        .select { |page| page.ordering > self.ordering } # Get pages with higher ordering
        .sort_by(&:ordering)                             # Sort them by ordering
        .first                                           # Get the closest next page
  end

  def prev
    self.application_for_offering.visible_pages
        .select { |page| page.ordering < self.ordering } # Get pages with lower ordering
        .sort_by(&:ordering)                             # Sort them by ordering
        .last                                            # Get the highest (closest) previous page
  end


    
end
