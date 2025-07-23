class CommunityEngagedMailer < ActionMailer::Base

  def templated_message(person, email_template, recipients, link, options = {})
	  @person     = person
    @text       = email_template.body.to_s    
    @link       = link

    # Merge any extra instance variables from options if needed:
    options.each do |key, value|
      instance_variable_set("@#{key}", value)
    end

    mail(to: recipients, subject: email_template.subject, from: email_template.from, date: Time.now)
  end

end