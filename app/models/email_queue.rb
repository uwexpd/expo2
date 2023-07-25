require 'mail'
class EmailQueue < ApplicationRecord
  stampable
  # EmailQueue.partial_updates = false # disable partial_updates so that serialized columns get saved
  
  belongs_to :person
  serialize  :email
  belongs_to :application_status
  belongs_to :original, :class_name => "ContactHistory", :foreign_key => "original_contact_history_id"
  belongs_to :contactable, :polymorphic => true
  
  # for activeadmin breadcrumb title display
  def display_name
    "#{id}"
  end

  # Adds a message to the queue.
  def self.queue(person, mail_object, application_status = nil, command_after_delivery = nil, original_contact_history = nil, contactable = nil)
    EmailQueue.create :person_id => person, 
                      :email => mail_object, 
                      :application_status_id =>  (application_status.nil? ? nil : application_status.id),
                      :command_after_delivery => command_after_delivery,
                      :original_contact_history_id => (original_contact_history.nil? ? nil : original_contact_history.id),
                      :contactable => (contactable.nil? ? nil : contactable)
  end
  
  # Returns true if there are messages waiting in the queue. This can be useful if you need to know if you should 
  # redirect a user to the email queue to handle messages. By default, this is based only on messages queued by the
  # current user. Pass ":all" as the first parameter to get all messages.
  def self.messages_waiting?(select = :current_user)
    EmailQueue.count(select) > 0
  end

  # Returns the number of messages in the queue. By default, this is based only on messages queued by the
  # current user. Pass ":all" as the first parameter to get all messages.
  def self.count(select = :current_user)
    EmailQueue.messages(select).size
  end

  # Returns the messages in the queue. By default, this is based only on messages queued by the
  # current user. Pass ":all" as the first parameter to get all messages.
  def self.messages(select = :current_user)
    conditions = (select == :current_user && User.current_user) ? { :creator_id => User.current_user.id } : { }
    EmailQueue.where(conditions)
  end
  
  # Returns the name of the person this email is being sent to, if available.
  def recipient_name
    person.nil? ? email.to.to_s : person.fullname
  end
  
  # Releases an email from the queue by sending the email and deleting this EmailQueue record. If a +command_after_delivery+ was specified
  # when this object was created, execute that command now as well.
  def release
    # Delivers by logging the encoded message to $stdout
    email.delivery_method :logger if Rails.env != 'production'
    
    if EmailContact.log(person_id, email.deliver!, application_status, original, contactable)
       self.destroy
    end
  end

  def email_to
    if email.class.name == "TMail::Mail"
      email['to'].as_json['body'] rescue ""
    else
      email.to rescue "error"
    end

  end

  def email_from
    if email.class.name == "TMail::Mail"
      email['from'].as_json['body'] rescue ""
    else
      email.from.first rescue "error"
    end    
  end

end
