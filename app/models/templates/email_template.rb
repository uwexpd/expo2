class EmailTemplate < TextTemplate

  validates_presence_of :from

  scope :order_by_name, -> { order(Arel.sql('LOWER(name)')) }
  
  # Creates an email or emails based on this EmailTemplate. If passed an array, then call this method on each of the array's members
  # and return an array of Mail objects. Otherwise, just return the one Mail object created.
  def create_email_to(object, link = nil, alternate_recipient = nil)
    self.reload
    if object.is_a?(Array)
      return object.collect{|r| self.create_email_to(r, link, alternate_recipient)}
    else      
      return TemplateMailer.text_message(object, from, subject, body, link, alternate_recipient)
    end
  end
  
end
