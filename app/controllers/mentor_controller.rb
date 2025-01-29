class MentorController < ApplicationController
  skip_before_action :check_if_contact_info_blank
  before_action :fetch_offering
  before_action :apply_alternate_stylesheet  
  before_action :check_if_contact_info_is_current, :except => ['update', 'map']
  before_action :fetch_breadcrumb

  def index
    @person = @current_user.person    
    if params[:offering_id]
      # @offering = Offering.find(params[:offering_id])
      @mentor_applications = @person.application_mentors.select{|m| m.offering.id == params[:offering_id].to_i }
      # logger.debug "#{@mentor_applicaitons}"
      @total_mentees_count = @mentor_applications.size
    else
      @total_mentees_count = @person.application_mentors.size
      @page_number = true
      @mentor_applications = @person.application_mentors.page(params[:page]).order('id desc')
    end
        
    render :action => 'index_abstract_approve' and return if @offering && @offering.mentor_mode == 'abstract_approve'
  end

  def mentee
    redirect_to :action => 'mentee_abstract_approve', :id => params[:id] and return if @offering && @offering.mentor_mode == 'abstract_approve'
    
    @person = @current_user.person
    @mentee_application_record = @person.application_mentors.find params[:id]
    @mentee_application_record.reload
    @mentee_application_record.create_answers_if_needed
    @mentee_application = ApplicationForOffering.find(@mentee_application_record.application_for_offering.id)
    @mentee = @mentee_application.person
    check_if_past_deadline unless @mentee_application_record.responded?
    if params[:application_mentor]
      @mentee_application_record.require_validations = true
      if @mentee_application_record.update(mentor_letter_params)
        if @mentee_application.submitted?
          if @offering.require_all_mentor_letters_before_complete?
            @mentee_application.set_status "complete" if @mentee_application.all_mentor_letters_received?
          else 
            @mentee_application.set_status "complete" if @mentee_application_record.letter_received?
          end
        else
          @mentee_application.set_status "in_progress"
        end
        @mentee_application_record.generate_token # generate a new token to invalidate the mapping emails
        @mentee_application_record.send_thank_you_email
#        @mentee_application_record.save!
        flash[:notice] = "Your letter for #{@mentee.fullname} was received. Thank you."
        redirect_to :action => "index"
      else        
        flash[:error] = "Something went wrong. Please check error message below."
      end
    end
        
    if params['file'] && @mentee_application.mentor_access_ok
      file_path = File.join(Rails.root, 'files', @mentee_application.files.find(params[:file]).file.original.url)
      send_file file_path unless file_path.nil?
    end
    if params['view'] == 'letter'
      file_path = File.join(Rails.root, 'files', @mentee_application_record.letter.original.url)
      send_file file_path unless file_path.nil?
    end    
  end
  
  # Approve Mentee abstract logic: 
  # Primary mentors (no matter what type of mentors) *AND*
  # other mentors who are meets_minimum_qualification need to approve the abstract, then the application status will be marked as completed.
  # Not_required_mentor should be able to enter academic dept even the application status is completed.
  def mentee_abstract_approve
    @person = @current_user.person
    @mentee_application_record = @person.application_mentors.find params[:id]
    @mentee_application_record.create_answers_if_needed
    @mentee_application = @mentee_application_record.application_for_offering
    @mentee = @mentee_application.person        
    @error_message = params["error_message"] if params["error_message"]    

    if @mentee_application_record.primary || @mentee_application_record.meets_minimum_qualification?
        @approval_display = true unless @mentee_application.passed_status?(:revision_submitted) || @mentee_application.passed_status?(:complete)
    else
        @approval_display = true unless @mentee_application_record.approved?
    end
    
    check_if_past_deadline unless @mentee_application_record.responded?
    if params["application_mentor"]
      selected_academic_department = params["application_mentor"]["academic_department"].blank? ? nil : params["application_mentor"]["academic_department"].delete_if(&:blank?)
      if selected_academic_department.blank?
         @error = "Please at least select one for your academic department(s)."
         flash[:error] = @error
         redirect_to :action => 'mentee_abstract_approve', :id => params[:id], :error_message => @error and return true
      else
        @mentee_application_record.update(academic_department: selected_academic_department)
      end
      
      if @mentee_application_record.update(mentor_approval_params)
        @mentee_application_record.update(approval_at: Time.now)
        if @mentee_application.submitted?
          @required_mentors = @mentee_application.reload.mentors.select{|m| m.primary || m.meets_minimum_qualification?}
          @mentee_application.set_status "complete" unless @required_mentors.collect(&:approved?).include?(false)
          @mentee_application.set_status "revision_needed" if @mentee_application_record.approval_response == 'revise'
          @mentee_application.set_status "mentor_denied" if @mentee_application_record.approval_response == 'no_with_explanation'
          @mentee_application.mentors.delete(@mentee_application_record) if @mentee_application_record.approval_response == 'listed_in_error'
        else
          @mentee_application.set_status "in_progress"
        end
        @mentee_application_record.generate_token # generate a new token to invalidate the mapping emails
        @mentee_application_record.send_thank_you_email
        flash[:notice] = "Your response was received. Thank you."
        redirect_to :action => "index"
      end
    end  
  end
    
  
  def update
    @person = @current_user.person
    if params["person"]
      @person.attributes = person_params
      @person.contact_info_updated_at = Time.now
      @person.require_validations = true
      if @person.save
        flash[:notice] = "Contact information saved"
        redirect_to :action => "index"
      end
    end
  end
  
  # Maps a user to a student. We do this because we can't safely match up the ApplicationForOffering record with the
  # ApplicationMentor's person record until the mentor logs in for the first time. So in emails that we send to the mentor,
  # we include a link to this action instead of the index action so that the user and student can be mapped if needed. Once
  # a mentor submits their letter (in the mentee action), we consider the mentor process closed, generate a new token, and
  # the original email link becomes useless as a mapping link -- in effect, it just redirects to the index action from this
  # point forward.
  def map
    if mentor = ApplicationMentor.find_using_token(params[:mentor_id], params[:token])
      mentor.person_id = @current_user.person.id
      mentor.save(validate: false)
    end
    redirect_to mentor_offering_path(@offering.id)
  end

  def letter 
    mentor = ApplicationMentor.find(params[:id])
    letter_path = "#{Rails.root}/files/application_mentor/letter/#{mentor.id}/#{mentor.letter.filename}"
    
    unless letter_path.nil?
      send_file letter_path, x_sendfile: true
    end    
  end

  def view_file
    file = ApplicationFile.find(params[:file_id]).file
    file_path = "#{Rails.root}/files/application_file/file/#{params[:id]}/#{file.filename}"
    unless file_path.nil?
      send_file file_path, x_sendfile: true
    end
  end
  
  protected
  
  # If the request includes an ApplicationMentor record (:mid) and access token (:t), then we assume that the currently logged in user
  # has access to this student and map the ApplicationMentor's person_id to the current user.
  def map_user_to_mentor
    if params[:mid] && params[:t] && mentor = ApplicationMentor.find_using_token(params[:mid], params[:t])
      mentor.person_id = @current_user.person.id
      mentor.save(validate: false)
    end
  end

  def fetch_offering
    @offering = Offering.find(params[:offering_id]) if params[:offering_id]
    @offering = @current_user.person.application_mentors.find(params[:id]).application_for_offering.offering if params[:id] rescue nil    
  end

  def fetch_breadcrumb
    add_breadcrumb "#{@current_user.person.fullname}"
    add_breadcrumb "Mentor Review", mentor_path
  end

  def apply_alternate_stylesheet
    if @offering && @offering.alternate_stylesheet
      @alternate_stylesheet = @offering.alternate_stylesheet
    end
  end
  
  # Checks to see if the contact information for this mentor is current. This is done by checking for a value in
  # person.contact_info_updated_at. If it is blank or older than 12 months, then redirect to the "update" page.
  def check_if_contact_info_is_current
    update_date = @current_user.person.contact_info_updated_at
    if update_date.blank? || Time.now - update_date > 12.months
      redirect_to :action => "update", :return_to => request.url
    end
  end

  # Blocks a mentor from accessing the current page if we're past the deadline.
  def check_if_past_deadline
    if @offering.mentor_deadline && @offering.deny_mentor_access_after_mentor_deadline && @offering.mentor_deadline < Time.now
      return raise ExpoException.new("The deadline for mentor submissions has passed.",
                                    "The deadline was #{@offering.mentor_deadline.to_s(:date_at_time12)}.",
                                    "If you have questions, contact #{@offering.contact_name} at #{(@offering.contact_email)}
                                    or #{@offering.contact_phone}.")
    end
  end

  private

  def person_params
      params.require(:person).permit(:firstname, :lastname, :email, :salutation, :title, :organization, :other_department, :phone, :box_no, :address1, :address2, :address3, :city, :state, :zip)
  end

  def mentor_letter_params
      params.require(:application_mentor).permit(:letter, :letter_content_type, :letter_size, answer_attributes: [:answer])
  end

  def mentor_approval_params
    params.require(:application_mentor).permit(:academic_department, :approval_response, :approval_comments, :confirm_primary)
  end
end
