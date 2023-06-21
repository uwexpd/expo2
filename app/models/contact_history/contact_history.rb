class ContactHistory < ApplicationRecord
  stampable
  
  belongs_to :person
  belongs_to :application_status
  belongs_to :original, :class_name => "ContactHistory", :foreign_key => "original_contact_history_id"
  has_many :related_messages, :class_name => "ContactHistory", :foreign_key => "original_contact_history_id"
  serialize :email

  belongs_to :contactable, :polymorphic => true

  scope :to_person, -> (person_id) { where('person_id = ?', person_id) }
  scope :from_user, -> (user_id) { where('person_id = ?', user_id) }

  # TODO Determines whether or not this user can see this contact history or not.
  def allows?(obj)
    true
  end

  def contact_email
    email.from.first.gsub(/\"/,'') rescue ""
  end

end
