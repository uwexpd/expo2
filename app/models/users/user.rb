require 'digest/sha1'
class User < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  model_stamper
  
  belongs_to :person
  has_many :roles, :class_name => "UserUnitRole", :foreign_key => "user_id" do
      def for(unit_id); find(:all, :conditions => { :unit_id => unit_id }); end
  end
  has_many :units, :through => :roles do
      def minus_exp; find(:all, :conditions => "abbreviation != 'exp'"); end
  end
  
  has_many :logins, :class_name => "LoginHistory"
  has_many :email_addresses, :class_name => "UserEmailAddress"
  belongs_to :default_email_address, :class_name => "UserEmailAddress", :foreign_key => "default_email_address_id"

  has_one :token_object, :class_name => "Token", :as => :tokenable
  
  MAX_TOKEN_AGE = 1.day
  
  # Returns the actual token from this User's +token_object+ or generates a new one if:
  # 
  #  * no token object exists yet
  #  * the existing token is older than the MAX_TOKEN_AGE.
  def token
    return create_token_object.token if token_object.nil? || Time.now - token_object.updated_at > MAX_TOKEN_AGE
    token_object.token
  end
  
  def create_token
    create_token_object
  end
    
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_accessor :allow_invalid_person
  
  # TODO: Rails 4.0 has removed attr_accessible and attr_protected feature in favor of Strong Parameters. 
  # You can use the Protected Attributes gem for a smooth upgrade path. 
  #attr_accessible :login, :email, :password, :password_confirmation, :identity_url, :person_attributes, :picture, :picture_temp  #, :person_id
  
  validates :login, presence: true
  validates :password, presence: true, :if => :password_required?
  validates :password_confirmation, presence: true, :if => :password_required?
  validates :password, length: { :in => 6..40 }, :if => :password_required?
  validates :password, confirmation: true, :if => :password_required?
  validates :person, presence: true, :unless => :allow_invalid_person?
  validates :login, length: {:in => 3..40 }
  validates :login, uniqueness: { :scope => [:type, :identity_type], case_sensitive: false }
    
  validates_associated :person, :if => :check_person, :unless => :allow_invalid_person?
  
  before_save :encrypt_password
  
  scope :admin, -> { where(admin: true) }
  

  # Pulls the current user out of Thread.current. We try to avoid this when possible, but sometimes we need 
  # to access the current user in a model (e.g., to check EmailQueue#messages_waiting?).
  def self.current_user
    Thread.current[:current_user]
  end

  def check_person
      return false if person.nil?
      unless person.is_a?(Student)
        return false if allow_invalid_person? # needed to let the pubcookie user not be validated
        person.require_validations = true
        return true
      else
        return false
      end
  end
  
  def person_attributes=(person_attributes)
    if person.nil?
      self.person = Person.new(person_attributes)
    else
      self.person.update_attributes(person_attributes)
    end
  end

  # Returns a user's full name based on person's info
  def fullname
    person.fullname_unknown? ? login : person.fullname rescue login
  end

  # Returns the user's firstname_first from the person record
  def firstname_first
    person.fullname_unknown? ? login : person.firstname_first rescue login
  end

  def firstname
    person.fullname_unknown? ? login : person.firstname rescue login
  end    
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil. Note that this method is
  # case-insensitive, so "Mike" and "mike" will both return the same user object.
  def self.authenticate(login, password)
    logger.info "User.authenticate: #{login}, ******"
    u = find_by_login_and_type(login, nil) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)  
    crypted_password == encrypt(password)
  end
  
  # Returns true if this user's roles include the requested role. This can be passed as a symbol or string.
  # If the user must have the role assigned for a specific unit, specify the unit object or ID as the second parameter.
  # Note that "global" roles (i.e., roles with no unit assigned) will always return true regardless of the
  # unit that is passed.
  def has_role?(role, unit = nil)
    if unit
      unit = Unit.find(unit) unless unit.is_a?(Unit)
      roles.for(unit.id).collect(&:to_sym).include?(role.to_sym) || roles.for(nil).collect(&:to_sym).include?(role.to_sym)
    else
      roles.collect(&:to_sym).include?(role.to_sym)
    end
  end

  # Returns the authorizations that this user has for the specified role in an array of UserUnitRoleAuthorization objects,
  # or nil if the user does not have the role assigned.
  def authorizations_for(role)
    auth_roles = roles.find(:all, :joins => :role, :include => :authorizations, :conditions => { "roles.name" => role.to_s })
    return nil if auth_roles.empty?
    auth_roles.collect(&:authorizations).flatten.compact
  end
  
  # Returns true if this user is assigned a role for the specified unit.
  def in_unit?(unit)
    unit = Unit.find(unit) if unit.is_a?(Numeric)
    units.include?(unit)
  end
  
  def assign_role(role)
    return false if role.blank?
    role_type = Role.find_by_name(role.to_s)
    return false if role_type.nil?
    return roles.find_by_role_id(role_type.id) if has_role?(role)
    roles.create(:role_id => role_type.id)
  end

  # Returns a user type such as Student, Standard Users(uw staff and faulty), Exteranl Users(non-uw users)
  def user_type
    if self.class.name == "PubcookieUser"
      type = self.identity_type == "Student" ? self.identity_type : "UW Standard user"
    else
      type = "External user"
    end
    type
  end

  
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
    def allow_invalid_person?
          allow_invalid_person
    end


  
end
