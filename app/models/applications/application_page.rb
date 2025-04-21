class ApplicationPage < ApplicationRecord
  stampable
  belongs_to :application_for_offering
  belongs_to :offering_page
  
  attr_accessor :ordering
  
  delegate :title, :hide_in_admin_view?, :hide_in_reviewer_view?, :to => :offering_page
  
  def ordering
    offering_page.ordering
  end

  def complete?
    return true if complete    
  end

  def passes_validations?
    offering_page.questions.each do |question|
      question.add_errors(self)
    end
    self.errors.empty?
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
