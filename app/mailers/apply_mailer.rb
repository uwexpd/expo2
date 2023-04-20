class ApplyMailer < ActionMailer::Base
# include Rails.application.routes.url_helpers

  def status_update(application_for_offering, email_template, recipients, sent_at = Time.now, 
                    link = apply_url(
                        host: Rails.configuration.constants["base_url_host"],
                        protocol: 'https', 
                        offering: application_for_offering.offering),
                    availability_link = apply_url(
                        host: Rails.configuration.action_mailer.default_url_options[:host],
                        protocol: 'https',
                        offering: application_for_offering.offering) + "/availability",
                    cc_to_feedback_person = false)

    @subject    = email_template.subject
    @subject.gsub!(/\%([a-z0-9_.]+)\%/) { |a| eval("application_for_offering.#{a.gsub!(/\%/,'')}") rescue nil }
    @application_for_offering = application_for_offering
    @text       = email_template.body.to_s
    @link       = link
    @availability_link = availability_link    
    @cc         = application_for_offering.final_feedback_person.email if cc_to_feedback_person && !application_for_offering.final_feedback_person.nil?    
    @recipients = recipients

    mail(to: @recipients, subject: @subject, from: email_template.from, date: sent_at)
  end
  
  def mentor_status_update(mentor, email_template, recipients, sent_at = Time.now, link = mentor_url(:host => Rails.configuration.constants["base_url_host"]))
    @subject    = email_template.subject.to_s
    @subject.gsub!(/\%mentee.([a-z0-9_.]+)\%/) { |a| eval("mentor.application_for_offering.person.#{a.gsub!(/\%mentee./,'').gsub!(/\%/,'')}") rescue nil }
    @mentor     = mentor
    @mentee     = mentor.application_for_offering.person
    @offering   = mentor.application_for_offering.offering
    @text       = email_template.body.to_s
    @link       = link
    @from       = email_template.from    
    @recipients = recipients

    mail(to: @recipients, subject: @subject, from: email_template.from, date: sent_at)
  end
  
  def group_member_status_update(group_member, email_template, recipients, sent_at = Time.now, link = apply_url(:host => Rails.configuration.constants["base_url_host"], :offering => offering))
    @subject      = email_template.subject.to_s
    @group_member = group_member
    @text         = email_template.body.to_s
    @link         = link    
    @recipients   = recipients

    mail(to: @recipients, subject: @subject, from: email_template.from, date: sent_at)
  end

  def mentor_thank_you(mentor, email_template, recipients, sent_at = Time.now, link = mentor_url(:host => Rails.configuration.constants["base_url_host"]))
    @subject    = email_template.subject.to_s
    @subject.gsub!(/\%mentee.([a-z0-9_.]+)\%/) { |a| eval("mentor.application_for_offering.person.#{a.gsub!(/\%mentee./,'').gsub!(/\%/,'')}") rescue nil }
    @mentor     = mentor
    @mentee     = mentor.application_for_offering.person
    @offering   = mentor.application_for_offering.offering
    @text       = email_template.body.to_s
    @link       = link
    @from       = email_template.from    
    @recipients = recipients

    mail(to: @recipients, subject: @subject, from: email_template.from, date: sent_at)
  end
  
  
  def mentor_no_email_warning(mentor, recipients, sent_at = Time.now)
    @subject    = "Mentor with no e-mail access notification"
    @mentor     = mentor
    @mentee     = mentor.application_for_offering.person    
    @sent_on    = sent_at
    @recipients = recipients

    mail(to: @recipients,
         subject: @subject,
         from: Rails.configuration.constants['system_help_email'],
         date: sent_at)
  end

  def interviewer_message(offering_interviewer, email_template, offering, 
                          link = interviewer_url(:host => Rails.configuration.constants["base_url_host"], :offering => offering),
                          invite_link = interviewer_url(:host => Rails.configuration.constants["base_url_host"], :offering => offering) + "/welcome")
    @subject     = email_template.subject
    @offering_interviewer = offering_interviewer
    @text        = email_template.body.to_s
    @link        = link
    @invite_link = invite_link
    @recipients  = offering_interviewer.person.email

    mail(to: @recipients, subject: @subject, from: email_template.from, date: sent_at)
  end

  def reviewer_message(offering_reviewer, email_template, offering, link = reviewer_url(:host => Rails.configuration.constants["base_url_host"], :offering => offering))
    @subject    = email_template.subject
    @offering_reviewer = offering_reviewer
    @text       = email_template.body.to_s
    @link       = link
    @recipients = offering_reviewer.person.email

    mail(to: @recipients, subject: @subject, from: email_template.from, date: sent_at)
  end


  def templated_message(person, email_template, recipients, link)
    @subject    = email_template.subject
    @person     = person
    @text       = email_template.body.to_s
    @link       = link
    @recipients = recipients

    mail(to: @recipients, subject: @subject, from: email_template.from, date: sent_at)
  end

end