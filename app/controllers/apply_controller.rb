class ApplyController < ApplicationController
  skip_before_action :login_required
  before_action :student_login_required_if_possible
  before_action :fetch_offering, :except => :list
  before_action :apply_alternate_stylesheet, :except => :list
  before_action :fetch_user_applications, :except => [:cancelled, :list]
  before_action :choose_application, :except => [:which, :cancelled, :list, :group_member_validation]
  before_action :redirect_to_group_member_area, :except => [:group_member_validation, :group_member, :which, :cancelled, :list]
  before_action :check_restrictions, :except => [:restricted, :cancelled, :list, :which, :group_member_validation]
  before_action :check_must_be_student_restriction, :except => [:restricted, :cancelled, :list, :which, :enter_code, :group_member_validation, :group_member]
  before_action :display_submitted_note, :except => [:restricted, :cancelled, :availability, :summary, :list, :which, :revise_abstract, :index, :accept, :group_member_validation]
  before_action :check_if_contact_info_blank
  before_action :fetch_breadcrumb, except: [:list]

  def index    
  end

  def list
    add_breadcrumb  "EXPD", "https://expd.uw.edu"
    add_breadcrumb  "Online Applications"
    @current_offerings = Offering.all.select{|o| o.open?}
    @current_offerings = @current_offerings.select{|o| o.unit.abbreviation == params[:offering] rescue false } if params[:offering]    
  end

  def which
    if params[:application_for_offering_id]
      if params[:application_for_offering_id] == 'new'
        new_app = @offering.application_for_offerings.new
        new_app.person_id = @current_user.person.id
        new_app.save!
        session[:application_for_offering_id] = new_app.id
      else
        session[:application_for_offering_id] = params[:application_for_offering_id]
      end
      redirect_to :action => "index"
    end
  end
  
  def enter_code
    if params[:code]
      if code = @offering.invitation_codes.find_by_code(params[:code])
        flash[:error] = "That invitation code has already been used. Please try again." and return unless code.available?
        code.assign_to(@user_application)
        redirect_to :action => "index"
      else
        flash[:error] = "That invitation code was invalid. Please try again."
      end
    end
  end

  def page
    @page = @offering.pages.find_by_ordering params[:page]
    @user_application.passes_validations?
  end
  
  def update

    # figure out which page to go to next
    @page = @offering.pages.find_by_ordering params[:page]
    page = @page.ordering
    page = @page.next.ordering if params[:next_button]
    page = @page.prev.ordering if params[:prev_button] 
    
    # Mark this page as started
    @user_application.start_page(@page)
    
    # stop this method if the application has already been submitted
    redirect_to :action => 'page', :page => page and return unless @user_application.user_editable?

    # mark this application as in progress
    @user_application.set_status('in_progress')

    # update the application's attributes
    @user_application.update(apply_params) if apply_params

    # add a mentor if needed
    if params[:add_mentor_button] && @user_application.more_mentors_ok?
      @user_application.mentors.create
      @user_application.skip_validations = true
    end
    
    # add a group member if needed
    if params[:add_group_member_button]
      @group_member = @user_application.group_members.create(group_member_params)
      if @group_member.errors.empty?
        @group_member.send_validation_email
        @group_member = nil # We clear out the instance variable so it won't show up in the "add new group member" pane
      end
    end
    
    # clear group members if needed
    if params[:group] == "no"
      @user_application.group_members.delete_all
    end
    
    # remove a mentor if needed
    if params[:remove_mentor]
      @user_application.mentors.find(params[:remove_mentor]).destroy
      redirect_to :action => 'page', :page => page and return
    end
    
    # remove a group_member if needed
    if params[:remove_group_member]
      @user_application.group_members.find(params[:remove_group_member]).destroy
      redirect_to :action => 'page', :page => page and return
    end
    
    # resend a group member validation email if needed
    if params[:resend_group_member]
      if @user_application.group_members.find(params[:resend_group_member]).send_validation_email
        flash[:notice] = "Successfully re-sent verification e-mail."
      else
        flash[:error] = "Could not send verification e-mail."
      end
      redirect_to :action => 'page', :page => page and return
    end
    
    # view abstract preview
    if params[:pdf_button]
      redirect_to :action => "abstract", :format => :pdf and return
    end       
    
    unless @user_application.skip_validations
    
      # check if the page passes validation
      if @user_application.page_passes_validations?(@page.id) && !(@group_member && @group_member.errors.any?)
        @user_application.current_page.update_attribute :complete, true #mark page as complete
        passes_validations = true
      end
    
      # move on to the next page if it's ok
      if passes_validations || params[:continue_anyway]
        flash[:notice] = "Application data saved."
        redirect_to :action => "review" and return if params[:review_button]
        redirect_to :action => "index" and return if params[:welcome_button]        
        redirect_to :action => 'page', :page => page and return
      end
    
    end

    # show the page again
    redirect_to action: 'page'
  end

  def help
    @question = OfferingQuestion.find params[:id]
    render layout: 'popup', text: "That question does not have any help text." and return if @question.help_text.blank?
    render layout: 'popup'
  end

  def review
    # render review.html.erb
  end
  
  def restricted
    # render restricted.html.erb
  end
  
  def cancel
    if @offering.past_deadline?
      flash[:error] = "You cannot cancel your application once the submission deadline has passed."
      redirect_to :action => "index" and return
    end
    if params[:confirm_cancel]
      @user_application.set_status "cancelled"
      @user_application.destroy
      redirect_to :action => 'cancelled' and return
    end
    # render cancel.html.erb
  end
  
  def cancelled
    session[:application_for_offering_id] = nil
    # render cancelled.html.erb
  end
  
  def group_member_validation
    @group_member ||= Token.find_object params[:group_member_id], params[:token], false
    @person = @current_user.person
    raise ExpoException.new("Invalid Link", "That verification link is not valid. Please ask your primary group member to resend a verification link to you.") and return unless @group_member
    @user_application = @group_member.application_for_offering
    
    if request.patch?
      @group_member.verified = params[:verified] == 'yes' ? true : false
      @group_member.person_id = @person.id
      if @group_member.verified?
        @person.require_validations = true
        @person.require_student_validations = true
        group_member_validation_params = @person.is_a?(Student) ? student_params : person_params
        if @person.update(group_member_validation_params) && @group_member.save
          flash[:notice] = "Thank you for confirming your group membership, #{@person.firstname}!"
          redirect_to :action => "index" and return
        else
          flash[:error] = "Could not save your group member record!"
        end
      else
        if @group_member.destroy
          render :text => "<h4>Thank you.</h4><p>You have been successfully removed from this application.</p>".html_safe, :layout => true
        else
          flash[:error] = "Oops, there was a problem removing you from this application."
        end
      end
    end
    
  end
  
  def submit    
    unless @offering.disable_signature?
      @user_application.electronic_signature = params[:user_application]['electronic_signature']
      @user_application.electronic_signature_date = Time.now
    end            
    if @user_application.passes_validations? && (@offering.disable_signature? || @user_application.electronic_signature_valid?)

      @user_application.set_status "submitted"

      if @offering.require_all_mentor_letters_before_complete?
        @user_application.set_status "complete" if @user_application.all_mentor_letters_received?
      else      
        @user_application.set_status "complete" if @user_application.mentor_letter_received?
      end

      # Send eamil notification for husky 100 process
      unless @offering.questions.where(display_as: 'husky100_netid').blank?
          send_husky_notifications
      end      
      redirect_to :action => 'index' and return      
    else
      @electronic_signature_error = true if !@user_application.electronic_signature_valid?
      render :action => 'review'
    end    

  end
  
  def availability
    if params[:commit]
      # @user_application.set_status "awaiting_summary"
      redirect_to :action => "summary"
    end
    # render availability.html.erb
  end

  def summary
    if params[:application_for_offering]
      @user_application.project_summary = params[:application_for_offering][:project_summary]
      if @user_application.save
        # @user_application.set_status "scheduling_interview"
        redirect_to :action => "index"
      end
    end
    # render summary.html.erb
  end

  def accept
    unless @user_application.awarded?
      flash[:error] = "You cannot go through the acceptance process without being awarded."
      return redirect_to :action => "index"
    end
    unless @offering.enable_award_acceptance?
      flash[:error] = "The award acceptance process is not enabled yet. Please try again later."
      return redirect_to :action => "index"
    end
    if @user_application.declined?
      flash[:error] = "You already declined your award."
      return redirect_to :action => "index"
    end
    if params[:application_for_offering]
      @user_application.declined = params[:application_for_offering][:declined]
      for i in 1..3
        r = params[:application_for_offering]["acceptance_response#{i}"]
        @user_application.update_attribute("acceptance_response#{i}", r) if r
      end
      @user_application.save
      if @user_application.declined?
        @user_application.set_status(@offering.declined_offering_status.application_status_name) if @offering.declined_offering_status
        flash[:notice] = "You have successfully declined your award."
        return redirect_to :action => "index"
      else
        @user_application.update_attribute(:award_accepted_at, Time.now)
        @user_application.set_status(@offering.accepted_offering_status.application_status_name) if @offering.accepted_offering_status
        flash[:notice] = "Thank you for accepting your award."
        return redirect_to :action => "index"
      end
    end
  end
  
  # Marks a person available for a specific interview timeslot
  def mark_available
    t = @user_application.interview_availabilities.find_or_create_by_time_and_offering_interview_timeblock_id(
                                                                          params[:time].to_time, params[:timeblock_id])
    render :partial => "timeslot_available", :locals => { :b => params[:timeblock_id], :ti => params[:ti], :time => params[:time] }
  end
  
  # Marks a person as unavailable for a specific interview timeslot
  def mark_unavailable
    t = @user_application.interview_availabilities.find_by_time_and_offering_interview_timeblock_id(
                                                                params[:time].to_time, params[:timeblock_id])
    t.destroy
    render :partial => "timeslot_not_available", :locals => { :b => params[:timeblock_id], :ti => params[:ti], :time => params[:time] }
  end
  
  # Generates a PDF version of the requested application_text
  def application_text
    @application_text = @user_application.text params[:title]
    respond_to do |format|
      format.pdf  { send_pdf @application_text.title }
      format.html { render :text => @application_text.body, :layout => false }
    end
  end
  
  # Generates a PDF version of the abstract (this is Symposium-specific)
  def abstract
    respond_to do |format|
      format.pdf  { send_pdf "Abstract", {}, :right => '10cm' }
    end
  end
  
  # Allows the applicant to submit a new revised abstract after the application has been submitted.
  def revise_abstract
    if !@user_application.status.offering_status.allow_abstract_revisions?
      flash[:error] = "Your abstract does not need a revision, so you are not allowed to submit a revised one."
      redirect_to :action => "index" and return
    end
    if request.patch?
      if params[:project_title].blank? || params[:revised_abstract].blank?
        return flash[:error] = "Please fill out content in the project title or abstract"
      else
        @user_application.text("Abstract").body = params[:revised_abstract]
        @user_application.project_title = params[:project_title]
        @user_application.save!
      end

      if @user_application.in_status?(:conditionally_accepted_full_revision_needed) || @user_application.in_status?(:conditionally_accepted_commented)
        # @user_application.set_status "final_revision_submitted"
        @user_application.set_status "fully_accepted"
        flash[:notice] = "Thank you for submitting your final revisions."
      else
        # check if there is one of primary OR required_mentors(faculty) who did NOT respond then set status +faculty_approval_needed+
        # Once ALL primary AND required mentors (faculty) have responded, set status +revision_submitted+
        required_mentors = @user_application.mentors.select{|m| m.primary || m.meets_minimum_qualification?}

        if required_mentors.collect(&:responded?).include?(false)
          @user_application.set_status "faculty_approval_needed"
        else
          @user_application.set_status "revision_submitted"
        end
        flash[:notice] = "Thank you for submitting your revised abstract. An email has been sent to your mentor."
      end
      redirect_to :action => "index" and return

    end
  end

  # Allows the applicant to confirm minor changes to their abstract that have been made by the staff.
  def confirm_abstract
    if !@user_application.status.offering_status.allow_abstract_confirmation?
      flash[:error] = "Your abstract does not need confirmation, so you are not allowed to access that page."
      redirect_to :action => "index" and return
    end
    if request.post?
      if params[:pdf_button]
        redirect_to :action => "abstract", :format => :pdf and return
      else
        @user_application.set_status "fully_accepted"
        flash[:notice] = "Thank you for confirming your abstract changes. You may now confirm your participation."
        redirect_to :action => "index" and return
      end
    end
  end

  # Return the student's uploaded file for them to review (useful for converted documents)
  def file
    # version = params[:version].nil? ? :original : params[:version].to_sym

    file = @user_application.files.find(params[:id]).file #.versions[version]        
    file_path = "#{Rails.root}/files/application_file/file/#{@user_application.id}/#{file.filename}"
    
    unless file_path.nil?
      send_file file_path, x_sendfile: true
    end
    # type = file.content_type
    # filename = file.public_filename
    # disposition = params[:disposition] == 'inline' ? 'inline' : 'attachment'
    # send_file file_path, :disposition => disposition, :type => (type || "text"), :filename => filename unless file_path.nil?
  end
  
  protected
  
  def fetch_offering
    @offering = Offering.find params[:offering]
    @reference_quarter = Quarter.find_by_date(@offering.deadline) rescue nil
  end
  
  def apply_alternate_stylesheet
    if @offering.alternate_stylesheet
      @alternate_stylesheet = @offering.alternate_stylesheet
    end
  end
  
  def fetch_user_applications
    @user_applications = ApplicationForOffering.where(person_id: @current_user.person.id, offering_id: @offering.id)
    @group_applications = ApplicationGroupMember.where(person_id: @current_user.person.id).select{|a| a.offering.id == @offering.id rescue false }
    @application_count = @user_applications.size + @group_applications.size
  end

  def choose_application
    if @user_applications.empty? && @group_applications.empty?
      @user_application = ApplicationForOffering.create(:person => @current_user.person, :offering => @offering)
    elsif @user_applications.size == 1 && @group_applications.empty?
      @user_application = @user_applications.first
    else
      if session[:application_for_offering_id].blank?
        redirect_to apply_which_url(@offering)
      else
        @user_application = ApplicationForOffering.find session[:application_for_offering_id]
        raise ExpoException.new("That is not a valid application ID.") and return if @user_application.nil?        
        if @user_applications.collect(&:id).include?(@user_application.id)
          @is_group_member = false
        elsif @group_applications.collect(&:application_for_offering).collect(&:id).include?(@user_application.id)
          @group_member = @group_applications.select{|a| a.application_for_offering_id == @user_application.id}.first
          @is_group_member = true
        else
          raise ExpoException.new("You are not allowed to access that application") and return
        end
      end
    end
  end

  def redirect_to_group_member_area
    redirect_to :action => 'group_member_validation' and return if @is_group_member && !@group_member.verified?
    redirect_to :action => 'group_member' and return if @is_group_member
  end
  
  def check_restrictions
    for restriction in @offering.restrictions do
      if !restriction.allows?(@user_application) && !restriction.exempt?(@user_application)
        @restriction = restriction
      end
    end
    render :action => "restricted" and return unless @restriction.nil?
  end

  # Runs the MustBeStudent restriction. This is done in a separate method because it needs to be checked before the other restrictions,
  # and we don't allow it to be overridden with an exemption. The Apply controller expects the user to have a Student record.
  # This filter can be bypassed by setting the +allow_students_only+ option in Offering to false.
  def check_must_be_student_restriction
    if @offering.allow_students_only?
      @restriction = MustBeStudentRestriction.new(:offering_id => @offering.id)
      render :action => "restricted" and return unless @restriction.allows?(@user_application)
    end
    if !@user_application.person.is_a?(Student) && @offering.require_invitation_codes_from_non_students?
      redirect_to apply_enter_code_path(@offering) and return if @user_application.offering_invitation_code.nil?
    end
  end

  def display_submitted_note
    unless @user_application.user_editable?
      flash[:notice] = "This application has already been submitted. It cannot be edited, but you can still review your responses."
    end
  end

  def fetch_breadcrumb
    add_breadcrumb  @offering.unit.name , @offering.unit.home_url
    add_breadcrumb "#{@offering.name} #{@offering.quarter_offered.title rescue nil}", apply_path
  end

  # For Husky 100 nominations specifically
  def send_husky_notifications
    sent_student_emails = []
          @offering.questions.where(display_as: 'husky100_netid').each do |question|
            input_netid = @user_application.get_answer(question.id)
            if input_netid
              uwnetid = input_netid.to_s.match(/^(\w+)(@.+)?$/).try(:[], 1)
              student = Student.find_by_uw_netid(uwnetid)
              unless student.nil?
                  template = EmailTemplate.find_by_name("Husky 100: Nominated Student First Notification")
                  if template
                      EmailContact.log  student.id, template.create_email_to(student, link = "#{@user_application.person.firstname_first}").deliver_now, @user_application.current_status
                      sent_student_emails << student.email
                  else
                      return flash[:error] = "Can not find the template to send: Husky 100: Nominated Student First Notification."
                  end
              end
            end
          end
          return flash[:notice] = "A notification email sent to #{sent_student_emails.join(', ')} for husky 100 nomination."
  end

  private

  def apply_params
      params.require(:user_application).permit! if params[:user_application]
      # (:project_title, :project_description, :hours_per_week, :project_dates, :other_scholarship_support, :local_or_permanent_address,
      #   person_attributes: [:salutation, :firstname, :lastname, :nickname, :email, :phone, :est_grad_qtr])
  end

  def person_params
    params.require(:person).permit(:salutation, :firstname, :lastname, :nickname, :email, :phone, :institution_id, :major_1, :major_2, :major_3, :class_standing_id, award_ids: {})
  end

  def student_params
    params.require(:student).permit(:salutation, :firstname, :lastname, :nickname, :email, :phone, :institution_id, :major_1, :major_2, :major_3, :class_standing_id, award_ids: {})
  end

  def group_member_params
      params.require(:group_member).permit(:firstname, :lastname, :uw_student, :email)
  end

end
