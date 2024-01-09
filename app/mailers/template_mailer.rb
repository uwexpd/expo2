class TemplateMailer < ActionMailer::Base

  def text_message(obj, from_text = "", subject_text = "", text = "", link = "", alternate_recipients = nil)
    @text = text
    @object = obj
    @link = link
    mail(to: alternate_recipients || (obj.respond_to?("email") ? obj.email : obj.person.email),
         subject: eval_subject_text(subject_text, obj),
         from: from_text,
         date: Time.now
        )
  end

  def html_message(obj, from_text = "", subject_text = "", text = "", link = "", alternate_recipients = nil)
    @text = text
    @object = obj
    @link = link
    mail(to: alternate_recipients || (obj.respond_to?("email") ? obj.email : obj.person.email),
         subject: eval_subject_text(subject_text, obj),
         from: from_text,
         date: Time.now,
         content_type: "text/html"
        )
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
