require 'digest/sha1'
class User < ActiveRecord::Base
  # belongs_to :person
  has_many :roles, :class_name => "UserUnitRole", :foreign_key => "user_id" do
      def for(unit_id); find(:all, :conditions => { :unit_id => unit_id }); end
  end
  has_many :units, :through => :roles do
      def minus_exp; find(:all, :conditions => "abbreviation != 'exp'"); end
  end
  
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  # attr_accessor :allow_invalid_person
  
  # TODO: Rails 4.0 has removed attr_accessible and attr_protected feature in favor of Strong Parameters. You can use the Protected Attributes gem for a smooth upgrade path. 
  #attr_accessible :login, :email, :password, :password_confirmation, :identity_url, :person_attributes, :picture, :picture_temp  #, :person_id
  
  validates :login, presence: true
  validates :password, presence: true, :if => :password_required?
  validates :password_confirmation, presence: true, :if => :password_required?
  validates :password, length: { :in => 6..40 }, :if => :password_required?
  validates :password, confirmation: true, :if => :password_required?
  # validates :person, presence: true, :unless => :allow_invalid_person?
  validates :login, length: {:in => 3..40 }
  validates :login, uniqueness: { :scope => [:type, :identity_type], case_sensitive: false }
    
  # validates_associated :person, :if => :check_person, :unless => :allow_invalid_person?
  
  before_save :encrypt_password
  
  scope :admin, -> { where(admin: true) }
  
  # def check_person
  #   return false if person.nil?
  #   unless person.is_a?(Student)
  #     return false if allow_invalid_person? # needed to let the pubcookie user not be validated
  #     person.require_validations = true
  #     return true
  #   else
  #     return false
  #   end
  # end
  
  
  
  protected
  
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end

    # In some cases, we want to be able to update user attributes without worrying about a valid person record.
    # An example is when we are reseting the password and the form only allows them to edit passwords.
    # def allow_invalid_person?
    #   allow_invalid_person
    # end
  
end
