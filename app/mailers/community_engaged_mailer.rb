class CommunityEngagedMailer < ActionMailer::Base
  layout 'email'

  def templated_message(person, email_template, recipients, link, options = {})
    @person     = person
    @text       = email_template.body.to_s    
    @link       = link
    @recipients = recipients
    @subject    = email_template.subject
    @from       = email_template.from
    @email      = recipients.is_a?(Array) ? recipients.first : recipients
    # Merge any extra instance variables from options if needed:
    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    mail(to: recipients, subject: @subject, from: @from, date: Time.now) do |format|
      format.html
      format.text
    end
  end
end