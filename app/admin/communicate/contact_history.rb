require 'tmail'
ActiveAdmin.register ContactHistory do
  config.sort_order = 'created_at_desc'
  config.per_page = [30, 50]
  batch_action :destroy, false
  actions :all, except: [:new]
  config.action_items.delete_if {|item| (item.name == :edit || item.name == :destroy) && item.display_on?(:show) }  
  menu parent: 'Tools'

  scope('Sent By Me', default: true) { |contact| contact.from_user(current_user.id) }
  scope :all
  

  action_item :requeue, only: :show do
    link_to 'Resend this message', requeue_admin_contact_history_path(contact_history)
  end

  member_action :requeue do 
    contact = ContactHistory.find(params[:id])
    session[:return_to_after_email_queue] = request.referer
    redirect_to edit_admin_email_queue_path(contact.requeue) and return
  end

  index pagination_total: false do
    column('Date'){|contact| link_to contact.updated_at.to_s(:long_time12), admin_contact_history_path(contact) }
    column('To'){|contact| contact.email_to unless contact.email.nil?}
    column('Subject'){|contact| contact.email.subject unless contact.email.nil? rescue 'Unknown'}
    column('View'){|contact| link_to "View", admin_contact_history_path(contact)}
  end
  
  show do
    attributes_table do
       row ('From') {|contact| contact.email_from rescue "" }
       # row ('Cc') {|contact| contact.email.creator.fullname rescue contact.creator.login rescue "(unknown)" }
       row ('To') {|contact| contact.email_to rescue "" }
       row ('Subject') {|contact| contact.email.subject  rescue "" }
       row ('Date') {|contact| contact.email.date rescue "" }       
       row ('Body') {|contact| simple_format(EmailBodyExtractor.extract(contact.email)[:text]) }
    end
  end

  filter :person_id, label: 'Search by Expo Pesron ID'


end