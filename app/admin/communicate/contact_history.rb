require 'tmail'
ActiveAdmin.register ContactHistory do  
  config.sort_order = 'created_at_desc'
  config.per_page = [30, 50]
  batch_action :destroy, false
  config.action_items.delete_if {|item| (item.name == :edit || item.name == :destroy) && item.display_on?(:show) }  
  menu label: "Contact History"
  menu parent: 'Tools'

  action_item :resend, only: :show do
    link_to 'Resend this message', admin_contact_history_path
  end

  index pagination_total: false do
    column('Date'){|contact| link_to contact.updated_at.to_s(:long_time12), admin_contact_history_path(contact) }
    column('To'){|contact| contact.email_to unless contact.email.nil?}
    column('Subject'){|contact| contact.email.subject unless contact.email.nil?}
    column('View'){|contact| link_to "View", admin_contact_history_path(contact)}
  end
  
  show do
    attributes_table do
       row ('From') {|contact| contact.email_from rescue "" }
       # row ('Cc') {|contact| contact.email.creator.fullname rescue contact.creator.login rescue "(unknown)" }
       row ('To') {|contact| contact.email_to rescue "" }
       row ('Subject') {|contact| contact.email.subject  rescue "" }
       row ('Date') {|contact| contact.email.date rescue "" }       
       row ('Body') {|contact| simple_format(contact.email.body.to_s) }
    end
  end

  filter :person_id, label: 'Search by Expo Pesron ID',  as: :string


end