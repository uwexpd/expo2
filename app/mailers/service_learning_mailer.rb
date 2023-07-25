class ServiceLearningMailer < ActionMailer::Base

	def templated_message(person, email_template, recipients, link)
	@person     = person    
    @text       = email_template.body.to_s    
    @link       = link
    @recipients = recipients

    mail(to: @recipients, subject: email_template.subject, from: email_template.from, date: Time.now)
  end

end