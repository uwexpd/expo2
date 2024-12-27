# An ApplicationForOffering may be sponsored by one or more ApplicationMentors.
class ApplicationMentor < ApplicationRecord
  self.per_page = 12
  # include ActionController::UrlWriter
  include Rails.application.routes.url_helpers

  stampable  
  belongs_to :application_for_offering
  delegate :offering, :to => :application_for_offering, allow_nil: true

  belongs_to :person
  delegate :address_block, :to => :person
  
  mount_uploader :letter, LetterUploader

  has_many :answers, :class_name => "ApplicationMentorAnswer" do
      def for(offering_mentor_question)
        find_by(offering_mentor_question_id: offering_mentor_question.id)
      end
  end
  delegate :mentor_questions, :to => :offering
  validates_associated :answers, :message => "to additional questions are not valid", :if => :require_validations?

  belongs_to :mentor_type, :class_name => "ApplicationMentorType", :foreign_key => "application_mentor_type_id"
  
  validates_presence_of :application_for_offering_id
   
  before_create :generate_token
    
  validates_size_of :letter, :maximum => 2000000, 
                    :message => "is too big; it must be smaller than 2 MB. Please upload a smaller file.",
                    :allow_nil => true,
                    :if => :require_validations?
  validates_presence_of :letter, :on => :update, :message => "must be submitted.", if: :require_validations?
  
  validate :is_pdf, if: :require_validations?
      
  after_save :send_invite_email_if_needed

  serialize :task_completion_status_cache
  serialize :academic_department
  has_many :task_completion_statuses, :as => :taskable, :class_name => "OfferingAdminPhaseTaskCompletionStatus"
  before_save :update_task_completion_status_cache!  

  attr_accessor :should_destroy
  attr_accessor :require_validations
  attr_accessor :send_invite_email_now
  attr_accessor :return_to
#  attr_accessor :email_confirmation
  
  scope :with_name, -> { where.not(firstname: [nil, ""]) }

  PLACEHOLDER_CODES = %w(login_link fullname firstname lastname email department)
  PLACEHOLDER_ASSOCIATIONS = %w(person application_for_offering mentee)
  
  # Alias for #self so that old email templates work
  def mentor; self; end
  
  # Alias for #application_for_offering.person
  def mentee
      application_for_offering.person
  end  
  
  # acts_as_soft_deletable
 
  # Supplies the filename to use when sending this file to the user's browser
  def public_filename
    filename = [id.to_s]
    filename << application_for_offering.person.lastname
    filename << "Mentor Letter"
    filename << "from"
    filename << person.fullname rescue nil
    filename.join(' ').gsub(/[^a-z0-9 ]+/i,'-') + ".#{extension}"
  end

  def extension
    if self.read_attribute(:letter).blank?
      self.read_attribute(:letter)
    else
      File.extname(self.read_attribute(:letter)).downcase.delete('.')      
    end
  end

  # 
  def login_link    
    mentor_offering_map_url(:host => Rails.configuration.constants["base_url_host"], :offering_id => offering.id, :mentor_id => id, :token => token)
  end
  #   
  def letter_received?
    !letter.file.nil?
  end
  
  def should_destroy?
    should_destroy.to_i == 1
  end
  
  def require_validations?
      require_validations
  end
  #   
  def send_thank_you_email(deliver_emails_now = true, status = nil)
    link = mentor_map_url(:host => Rails.configuration.constants["base_app_url"], :mentor_id => self.id, :token => self.token)
    email_template = offering.mentor_thank_you_email_template
    unless email_template.nil?
      if deliver_emails_now
        EmailContact.log person_id, ApplyMailer.mentor_thank_you(self, email_template, self.email, nil, link).deliver_now
      else
        EmailQueue.queue mentor.person_id, ApplyMailer.mentor_status_update(self, email_template, self.email, nil, link).message
      end
    end
  end    

  def type_title
    primary == true ? "Mentor" : "Secondary Mentor"
  end

  def person_id
    person.nil? ? nil : person.id
  end

  # Returns a string of text summarizing this mentor. Includes name, department, and organization if not UW
  def info_detail_line(include_html = false, academic_department = false, delimiter = ", ")
      if person.nil?
        line = ""
        fp = "<span class=\"mentor_name\">" if include_html
        fs = "</span>" if include_html
        line << "#{fp}#{fullname}#{fs}"
        line << (email.nil? ? " (No email given)" : " (#{email})")
      else
        fp = "<span class=\"mentor_name\">" if include_html
        fs = "</span>" if include_html
        dp = "<span class=\"mentor_department\">" if include_html
        academic_dpet = self.academic_department.join(delimiter) rescue self.academic_department
        department_name = academic_department==true ? academic_dpet : person.department_name 
        line = ["#{fp}#{fullname}#{fs}", "#{dp}#{department_name}#{fs}"]
        line << person.organization unless (person.organization.to_s == Rails.configuration.constants['university_name'] or person.organization.to_s == "UW")
        line = line.compact.delete_if{|x| x.blank?}.join(', ')
      end
      line
    end
  
  def fullname
    "#{firstname} #{lastname}"
  end

  # for activeadmin breadcrumb title display
  def display_name
    "#{fullname}"
  end

  def firstname
    if person.nil? || person.firstname.blank?
      # read_attribute(:firstname).blank? ? "(No first name given)" : "#{read_attribute(:firstname)}".strip
      read_attribute(:firstname)
    else
      "#{person.firstname}".strip
    end
  end
  
  def lastname
    if person.nil? || person.lastname.blank?
      # read_attribute(:lastname).blank? ? "(No last name given)" : "#{read_attribute(:lastname)}".strip
      read_attribute(:lastname)
    else
      "#{person.lastname}".strip
    end
  end
  
  # Similar to fullname.
  def lastname_first
    return person.lastname_first if !person.nil? && person.lastname_first != ", "
    "#{lastname}, #{firstname}".strip
  end

  # Similar to fullname.
  def firstname_first
    return person.firstname_first if !person.nil?
    "#{firstname} #{lastname}".strip
  end
  
  def email
    if person.nil? || person.email.blank?
      # read_attribute(:email).blank? ? "(No email given)" : "#{read_attribute(:email)}"
      read_attribute(:email)
    else
      "#{person.email}"
    end
  end
  
  def department
    person.department_name unless person.nil?
  end  
  
  def new_person_attributes=(new_person_attributes)
    if new_person_attributes[:id] == "-1"
      build_person(new_person_attributes.reject{|k,v| k == :id})
    elsif person
      person.update_attributes(new_person_attributes.reject{|k,v| k == :id})
    elsif person = (Person.find(new_person_attributes[:id]) rescue nil)
      person.update_attributes(new_person_attributes.reject{|k,v| k == :id})
    end
  end

  def answer_attributes=(answer_attributes)
      answer_attributes.each do |answer_id, attributes|
        answers.find(answer_id).update_attributes(attributes)
      end
    end

  def answer_for(offering_mentor_question)
      a = answers.find_or_create_by(offering_mentor_question_id: offering_mentor_question.id)
      unless a.valid?
        a.skip_validations = true
        a.save
      end
      a
    end

  def create_answers_if_needed
      mentor_questions.each do |q|
        answer_for q
      end
    end
  
  def generate_token
    write_attribute :token, random_string(10)
  end
  
  def random_string( len )
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    newpass
  end

  # Find an ApplicationMentor record using a secret token. After this use, a new token is generated so that the original cannot be reused.
  def self.find_using_token(id, token)
    m = ApplicationMentor.find_by_id_and_token id, token
    # m.generate_token unless m.nil?  # DO NOT regenerate the token automatically
    m
  end
  
  # Returns true if an invitation email has been sent to this mentor yet. This is especially useful to determine if a mentor is
  # an "early mentor", meaning that they were asked to submit a letter of recommendation before the student actually submitted their
  # completed application.
  def invite_email_sent?
    !invite_email_sent_at.blank?
  end

  # Sends the invite e-mail to this mentor using the template specified in the Offering's +early_mentor_invite_email_template_id+ attribute.
  def deliver_invite_email(template = offering.early_mentor_invite_email_template)
      link = mentor_offering_map_url(host: Rails.configuration.constants['base_url_host'], offering_id: offering.id, mentor_id: id, token: token, protocol: 'https')     
      
      if EmailContact.log(person_id, ApplyMailer.mentor_status_update(self, template, email, nil, link).deliver_now, application_for_offering.status)
        update_attribute(:invite_email_sent_at, Time.now)
      end
  end

  # Checks to see if the +send_invite_email_now+ attribute is set to true, and invokes the deliver_invite_email method if necessary.
  def send_invite_email_if_needed
      if send_invite_email_now == "1" && application_for_offering.page_passes_validations?(application_for_offering.current_page.offering_page)
        self.send_invite_email_now = false
        deliver_invite_email    
      end
  end

  # Returns true if there is a date in the +mentor_letter_sent_at+ field.
  def mentor_letter_sent?
    !mentor_letter_sent_at.blank?
  end
  
  # Generates the text of the mentor letter to be sent to the mentor. If a customized award letter text has been written to the
  # database, then we return that. Otherwise, we generate the text by parsing the template defined with 
  # Offering#mentor_award_letter_template_id.
  def mentor_letter_text
    return read_attribute(:mentor_letter_text) unless read_attribute(:mentor_letter_text).blank?
    template = offering.mentor_award_letter_template
    template.parse(self) if template
  end
  
  # Returns true if there is custom text stored in the +mentor_letter_text+ attribute.
  def custom_mentor_letter_text?
    !read_attribute(:mentor_letter_text).blank?
  end

  # Marks the mentor letter as being sent. This also parses and stores the templated letter so that the actual version is always stored 
  # in the database for the long-term.
  def send_mentor_letter
    update_attribute(:mentor_letter_sent_at, Time.now)
    update_attribute(:mentor_letter_text, mentor_letter_text)
  end

  # Returns true if this mentor's OfferingMentorType meets the minimum qualification for this Offering. Returns nil if this mentor
  # has no mentor type defined.
  def meets_minimum_qualification?
    return nil if mentor_type.nil?
    OfferingMentorType.find_by(application_mentor_type_id: mentor_type, offering_id: offering).meets_minimum_qualification?
  end
  
  # Returns true if the +approval_response+ is 'approved'. Because there can be multiple approval responses, this field is stored as text.
  def approved?
    approval_response == 'approved'
  end
  
  # Returns true if +approval_response+ is blank.
  def responded?
    !approval_response.blank?
  end

  # Returns an array of other applications for this offering where this mentor is also listed as a mentor.
  def other_mentees
      ApplicationMentor.joins(:application_for_offering).where( person_id: person_id, "application_for_offerings.offering_id" => application_for_offering.offering_id).reject{|x| x == self} if self.person_id
  end

  # Goes through this Offering's phase tasks (with "mentors" context) and checks the completion criteria for each. Then
  # populates the +task_completion_status_cache+ hash using OfferingAdminPhaseTask id's as keys and the
  # the attributes hash from OfferingAdminPhaseTaskCompletionStatus as values. If you just want to reset the cache
  # for a specific set of tasks, pass the task as a parameter.
  def update_task_completion_status_cache!(tasks = nil)
      self.task_completion_status_cache ||= {}
      tasks ||= offering.tasks.where("context = 'mentors' AND completion_criteria != ''")
      tasks = tasks.to_a unless tasks.is_a?(Array)
      for task in tasks
        tcs = task_completion_statuses.find_or_initialize_by(task_id: task.id)
        tcs.result = self.instance_eval(task.completion_criteria.to_s)
        tcs.complete = tcs.result == true
        tcs.save
        # Covert time object to string in attributes in order to be compatible with ruby 1.8
        tcs_attr = tcs.attributes
        tcs_attr["created_at"] = tcs_attr["created_at"].to_s if tcs_attr["created_at"]
        tcs_attr["updated_at"] = tcs_attr["updated_at"].to_s if tcs_attr["updated_at"]
        self.task_completion_status_cache[task.id] = tcs_attr
      end
      task_completion_status_cache
  end
  
  # Returns the task completion status hash for the specified task out of the +task_completion_status_cache+ hash. If the cache hasn't
  # been generated yet, this forces a reload (you can also manually force a reload by pass +true+ for +force_reload+).
  def task_completion_status(task_id, force_update = false)
      save if task_completion_status_cache.nil? || force_update
      task_completion_status_cache[task_id]
  end

  # Marks a certain task complete. Note that this should only be done for tasks that don't have a +completion_criteria+ set,
  # otherwise your action here will get overridden when #update_task_completion_status_cache! is run.
  def complete_task(task)
      self.task_completion_status_cache ||= {}
      task = OfferingAdminPhaseTask.find(task) unless task.is_a?(OfferingAdminPhaseTask)
      tcs = task_completion_statuses.find_or_create_by(task_id: task.id)
      tcs.result = true
      tcs.complete = true
      tcs.save
      # Covert time object to string in attributes in order to be compatible with ruby 1.8
      tcs_attr = tcs.attributes
      tcs_attr["created_at"] = tcs_attr["created_at"].to_s if tcs_attr["created_at"]
      tcs_attr["updated_at"] = tcs_attr["updated_at"].to_s if tcs_attr["updated_at"]
      self.task_completion_status_cache[task.id] = tcs_attr
      tcs
  end

  private

  def is_pdf
    if self.letter? && !self.letter_content_type.in?("application/pdf")  
      errors.add(:letter, 'must be uploaded with PDF file.')
    end
  end
end
