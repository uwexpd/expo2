class TemplateMailer < ActionMailer::Base
  layout 'email'

  def text_message(obj, from_text = '', subject_text = '', text = '', link = '', alternate_recipients = nil)
    @text = text
    @object = obj
    @link = link
    @recipients = alternate_recipients || (obj.respond_to?('email') ? obj.email : obj.person.email)
    @subject = eval_subject_text(subject_text, obj)
    # Footer email for layout
    @email = @recipients.is_a?(Array) ? @recipients.first : @recipients
    mail(to: @recipients, subject: @subject, from: from_text, date: Time.now) do |format|
      format.html
      format.text
    end
  end

  def html_message(obj, from_text = '', subject_text = '', text = '', link = '', alternate_recipients = nil)
    @text = text
    @object = obj
    @link = link
    @recipients = alternate_recipients || (obj.respond_to?('email') ? obj.email : obj.person.email)
    @subject = eval_subject_text(subject_text, obj)
    # Footer email for layout
    @email = @recipients.is_a?(Array) ? @recipients.first : @recipients
    mail(to: @recipients, subject: @subject, from: from_text, date: Time.now) do |format|
      format.html      
    end
  end

  private
  def eval_subject_text(subject_text, obj)
    if obj.is_a?(Hash)
      subject = subject_text.to_s.gsub(/\%([a-z0-9_]+).([a-z0-9_]+)\%/) { |a| eval("obj[:#{a[$1]}].#{a[$2]}") rescue nil }
    else
      subject = subject_text.to_s.gsub(/\%([a-z0-9_.]+)\%/) { |a| eval("obj.#{a.gsub!(/\%/,'')}") rescue nil }
    end
    subject
  end
end
