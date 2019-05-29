# Autoload Rails Models
# see https://github.com/collectiveidea/delayed_job/blob/master/lib/delayed/psych_ext.rb
# see https://github.com/ruby/psych/issues/252
# solution for EmailQueue/ContactHistory serialize email object's undefined class::TemplateMailer
Psych::Visitors::ToRuby.prepend Module.new {
  def resolve_class(klass_name)
    klass_name && klass_name.safe_constantize || super
  end
}