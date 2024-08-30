  ActiveAdmin.register_page "Apply" do
  menu false
  
  breadcrumb do
  	breadcrumbs = [
      link_to('Expo', "/expo"), 
      link_to('Online Applications', '/expo/admin/offerings'),
      
    ]
    if controller.instance_variable_get(:@offering)
      offering_link = link_to(controller.instance_variable_get(:@offering).title, "/expo/admin/apply/#{controller.instance_variable_get(:@offering).id}")
      breadcrumbs << offering_link
    end

    if controller.instance_variable_get(:@phase)
      task_link = link_to(controller.instance_variable_get(:@phase).name, "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}/phases/#{controller.instance_variable_get(:@phase).id}")
      breadcrumbs << task_link
    end

    breadcrumbs
  end

  controller do
  	before_action :fetch_offering, except: [:dean_approve, :finaid_approve, :disberse]
  	before_action :fetch_apps, only: [:list, :awardees, :mentors]
    before_action :fatch_phase, only: [:task, :mass_update, :edit_interview, :update_interview]
    before_action :fatch_task, only: [:task, :edit_interview, :update_interview]
    before_action :fetch_confirmers, :only => [:invited_guests, :nominated_mentors, :theme_responses, :proceedings_requests]

  	def manage
  		@phase = @offering.current_offering_admin_phase
  	end 

  	def list
  	end

    def awardees
      @awardees = @apps.select{|a| a.awarded? }
      
      respond_to do |format|
        format.html # awardees.html.erb
        format.xlsx  { render xlsx: 'awardees' }
      end  		
    end

    def mentors
      @apps.reject! {|a| !a.awarded? }      
      
      respond_to do |format|
        format.xlsx { render xlsx: 'mentors' }
      end
    end

    def phase      
      @phase = @offering.phases.find params[:id]
      @page_title = "#{@phase.name}"
    end

    def task      
      @page_title = "#{@task.title}"
      # [TODO] make this work: add_breadcrumb "#{@phase.name}", admin_apply_phase_path(@offering, @phase)
    end

    def mass_update
      if params[:tasks]
        params[:tasks].each do |task,values|          
          @phase.tasks.find(task).update(complete: values[:complete])
        end
      end      
      respond_to do |format|
        format.js 
        # { render :partial => "admin/apply/phases/tasks/sidebar_task", :collection => @phase.tasks }
      end
    end

    def show
      @app = @offering.application_for_offerings.find params[:id]
      if params['section']
        respond_to do |format|
          format.html { return redirect_to :action => :show, :anchor => params[:section] }
          format.js   { return render :partial => "admin/apply/section/#{params[:section]}", :locals => { :admin_view => true } }
        end
      end
    end

    def view
      @app = ApplicationForOffering.find params[:id]

      if params[:file]
        filepath = @app.files.find(params[:file]).file.filepath
      elsif params[:mentor]
        mentor_id = params[:mentor]
        filepath = letter = @app.mentors.find(mentor_id).letter.filepath
    end
      send_file(filepath, x_sendfile: true) unless filepath.nil?
    end

    def switch_to
      @phase = OfferingAdminPhase.find params[:id]
      @offering.current_offering_admin_phase = @phase
      @offering.save
      redirect_to :action => "phase", :id => @phase
    end

    def mass_status_change
      if params[:new_status] && params[:select]
        params[:select].each do |klass, select_hash|
          select_hash.each do |app_id,v|
            ApplicationForOffering.find(app_id).set_status(params[:new_status], false, :force => true) unless params[:new_status].blank?
          end
        end

        flash[:notice] = "Successfully update the status to #{params[:new_status]} with selected applications"        
        session[:return_to_after_email_queue] = request.referer
        redirect_to admin_email_queues_path and return if EmailQueue.messages_waiting?
      end
      redirect_to_action = params[:redirect_to_action] || "index"
      redirect_to session[:return_to_after_email_queue] || request.referer || url_for(:action => redirect_to_action)
    end

    def mass_assign_reviewers
      session[:return_to_after_email_queue] = request.referer
      session[:flash_message_assign_reviewer] = ""

      if params[:new_status] && params[:select] && params[:reviewer]
        params[:select].each do |klass, select_hash|
          select_hash.each do |app_id,v|
            params[:reviewer].each do |reviewer_id,v|
              app = ApplicationForOffering.find(app_id)
              if @offering.review_committee.nil?
                app.add_reviewer(reviewer_id) # add an offering_reviewer
              else
                # add a review committee member
                committee_member = CommitteeMember.find(reviewer_id)
                unless app.add_reviewer(committee_member)                 
                  session[:flash_message_assign_reviewer] << "[ALERT] #{committee_member.fullname rescue reviewer_id} is also the app mentor. Could NOT assign them to the application. "
                end
              end             
            end            
          end
        end
      end

      if params[:change_status]
        params[:select].each do |klass, select_hash|
          select_hash.each do |app_id,v|
            ApplicationForOffering.find(app_id).set_status(params[:new_status], false, :force => true) unless params[:new_status].blank?
          end
        end
        flash[:notice] = (session[:flash_message_assign_reviewer].blank? ? "" : session[:flash_message_assign_reviewer]) + "Successfully add reviwers and update the status to #{params[:new_status]} with selected applications. "        
      end
      redirect_to_action = params[:redirect_to_action] || "index"
      redirect_to session[:return_to_after_email_queue] || url_for(:action => redirect_to_action)
    end

    def send_interviewer_invite_emails
      return false if params[:email_template_id].nil?
      unless params[:select].present?
          flash[:alert] = "You must select at least one recipient to send the message to."
          redirect_back(fallback_location: root_path) and return
      end
      email_template = EmailTemplate.find(params[:email_template_id])
      params[:select].each do |klass, select_hash|
        select_hash.each do |object_id,v|
          @offering.interviewers.find_all{|r| r.id == object_id.to_i}.each do |i|
            if i.is_a?(OfferingInterviewer)
              if email_template.name.downcase.include?("interviewer invite")
                ufield = "invite_email_contact_history_id"
              elsif email_template.name.downcase.include?("interviewer interview times")
                ufield = "interview_times_email_contact_history_id"
              elsif email_template.name.downcase.include?("interviewer no interviews")
                ufield = "interview_times_email_contact_history_id"
              end
              if ufield
                command_after_delivery = "OfferingInterviewer.find(#{i.id}).update_attribute('#{ufield}', @email_contact.id)"
              end
            end
            EmailQueue.queue i.person.id,
                              ApplyMailer.interviewer_message(i, email_template.reload, @offering).message,
                              nil,
                              command_after_delivery
          end
        end
      end
      flash[:notice] = "Successfully queued e-mails to interviewers."
      session[:return_to_after_email_queue] = request.referer
      redirect_to admin_email_queues_path and return if EmailQueue.messages_waiting?
      redirect_to :back
    end

    def add_interview
      @interview = @offering.interviews.create(interview_time_params)
      if @interview.save
          unless params[:offering_interview][:applicant_id].blank?
            @interview.applicants.create(application_for_offering_id: params[:offering_interview][:applicant_id])
          end
          if params[:interviewers]
            params[:interviewers].each do |i|
              @interview.interviewers.create(offering_interviewer_id: i)
            end
          end
          flash[:notice] = "Successfully created interview time."
      else        
        flash[:alert] = "Something went wrong when creating interview time."
      end            
      redirect_to request.referer
    end

    def edit_interview
      @interview = @offering.interviews.find_by_id params[:interview]
    end

    def update_interview      
      @interview = @offering.interviews.find_by_id params[:interview]
      if @interview.update(interview_time_params)
        @interview.applicants.delete_all
        @interview.interviewers.delete_all
        unless params[:offering_interview][:applicant_id].blank?
          @interview.applicants.create(application_for_offering_id: params[:offering_interview][:applicant_id])
        end
        if params[:interviewers]        
          params[:interviewers].each do |i|
            @interview.interviewers.create(offering_interviewer_id: i)
          end
        end
        flash[:notice] = "Successfully updated interview time information."
        redirect_to admin_apply_phase_task_path(@offering, @phase, @task)
      else
        render :action => "edit_interview"
      end
    end

    def remove_interview
      OfferingInterview.find(params[:interview]).destroy
      respond_to do |format|        
        format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut();});"}
      end
    end

    def new_interview_timeblock
      if interview_timeblock_params
        flash[:notice] = "Added new interview timeblock." if @offering.interview_timeblocks.create interview_timeblock_params
      end
      redirect_to request.referer
    end
    
    def remove_interview_timeblock
      if params[:time]
        flash[:notice] = "Deleted interview timeblock." if @offering.interview_timeblocks.find(params[:time]).destroy
      end
      redirect_to request.referer
    end

    # This method can actually be used to send any emails to reviewers, not just invite emails.
    def send_reviewer_invite_emails
      return false if params[:email_template_id].nil?
      unless params[:select].present?
          flash[:alert] = "You must select at least one recipient to send the message to."
          redirect_back(fallback_location: root_path) and return
      end
      params[:select].each do |klass, select_hash|
        select_hash.each do |object_id,v|
          @offering.reviewers.find_all{|r| r.id == object_id.to_i}.each do |r|
            EmailQueue.queue r.person.id,  ApplyMailer.reviewer_message(r, EmailTemplate.find(params[:email_template_id]), @offering).message
          end
        end
      end
      flash[:notice] = "Successfully queued e-mails to reviewers."
      session[:return_to_after_email_queue] = request.referer
      redirect_to admin_email_queues_path and return if EmailQueue.messages_waiting?
      redirect_back(fallback_location: admin_apply_manage_path)
    end

    def assign_review_decision
      @app = @offering.application_for_offerings.find(params[:app_id]) rescue nil
      @review_decision = @offering.application_review_decision_types.find(params[:decision_type_id]) rescue nil

      if @app.nil?
        flash[:alert] = "Could not find an application with that ID."
      elsif @review_decision.nil?
        flash[:alert] = "Could not find review decision type with that ID."
      elsif @app.update(application_review_decision_type_id: @review_decision.id) && @app.set_status("reviewed")
        flash[:notice] = "Successfully assigned review decision to #{@app.firstname_first}'s application."
      else
        flash[:alert] = "Error assigning review decision to application."
      end

      respond_to do |format|        
          format.html { redirect_back(fallback_location: admin_apply_manage_path) }        
      end
    end

    def mini_details
      @app = @offering.application_for_offerings.find(params[:app_id]) rescue nil

      respond_to do |format|            
        if @app.nil?
          format.js
        else
          format.html { render partial: "mini_details" }
        end
      end
    end

    def notify_dean
      if params[:dean_approver_uw_netid]
        dean_approver = PubcookieUser.authenticate(params[:dean_approver_uw_netid])
        @offering.update(dean_approver_id: dean_approver.id)
        EmailContact.log dean_approver.person.id, 
            ApplyMailer.templated_message(dean_approver.person, 
            EmailTemplate.find_by_name("dean approval request"), 
            dean_approver.person.email,             
            "https://#{Rails.configuration.constants["base_url_host"]}/admin/apply/dean_approve").deliver_now
        flash[:notice] = "Request for dean approvals sent."
      end
      if params[:new_status] && params[:select]
        params[:select].each do |klass, select_hash|
          select_hash.each do |app_id,v|
            ApplicationForOffering.find(app_id).set_status(params[:new_status], false, :force => true) unless params[:new_status].blank?
          end
        end
      end
      redirect_to request.referer
    end

    def send_to_financial_aid
      if params[:financial_aid_approver_uw_netid]
        financial_aid_approver = PubcookieUser.authenticate(params[:financial_aid_approver_uw_netid])
        @offering.update_attribute(:financial_aid_approver_id, financial_aid_approver.id)
      end
      if params[:disbersement_approver_uw_netid]
        disbersement_approver = PubcookieUser.authenticate(params[:disbersement_approver_uw_netid])
        @offering.update_attribute(:disbersement_approver_id, disbersement_approver.id)
      end
      if params[:new_status] && params[:select]
        params[:select].each do |app_id,v|
          app = ApplicationForOffering.find(app_id)
          app.set_status params[:new_status] unless params[:new_status].blank?
          @offering = app.offering
        end
        EmailContact.log @offering.financial_aid_approver.person.id, 
            ApplyMailer.templated_message(@offering.financial_aid_approver.person, 
            EmailTemplate.find_by_name("financial aid approval request"), 
            @offering.financial_aid_approver.person.email, 
            "https://#{Rails.configuration.constants["base_url_host"]}/admin/apply/finaid_approve").deliver_now
        flash[:notice] = "Request for financial aid approvals sent."
        @offering.update(financial_aid_approval_request_sent_at: Time.now)
      end
      redirect_to request.referer
    end

    def scored_selection
      @cutoff = params[:cutoff] || nil
      @updated_apps = []
      @max_number_of_scores ||= 4

      @committee_mode = @offering.review_committee_submits_committee_score?
      @attribute_to_update = @committee_mode ? :application_final_decision_type_id : :application_review_decision_type_id

      if params[:details]
        @app = @offering.application_for_offerings.find(params[:id])
      end

      if params[:reset]
        @apps ||= @offering.application_for_offerings.reject{|a| a.reviewers.empty?}
        @apps.each{|a| a.update_attribute(@attribute_to_update, nil)}
        redirect_to :action => "scored_selection" and return
      end

      if params[:cutoff]
        if @committee_mode
          yes_option_id = @offering.application_final_decision_types.yes_option.id
          no_option_id = @offering.application_final_decision_types.no_option.id
          @apps ||= @offering.application_for_offerings.find(:all, 
                      :joins => :application_review_decision_type, 
                      :conditions => { "application_review_decision_types.yes_option" => true })
          @apps = @apps.sort_by{|x| (x.weighted_combined_score if x.weighted_combined_score > 0) || -1 }.reverse
          @score_attribute = "weighted_combined_score"
        else
          yes_option_id = @offering.application_review_decision_types.yes_option.id
          no_option_id = @offering.application_review_decision_types.no_option.id
          @apps ||= @offering.application_for_offerings.reject{|a| a.reviewers.empty?}.sort_by(&:average_score).reverse
          @score_attribute = "average_score"
        end
        for app in @apps
          if app.instance_eval(@score_attribute) > params[:cutoff].to_f
            app.update_attribute(@attribute_to_update, yes_option_id)
            @updated_apps << app
          else
            app.update_attribute(@attribute_to_update, no_option_id)
            @updated_apps << app
          end
        end
        respond_to do |format|
          format.html { return redirect_to :action => "scored_selection" }
          format.js { return }          
        end
      end
        
      if params[:decision_type_id]
        @app = @offering.application_for_offerings.find(params[:id])
        @app.update_attribute(@attribute_to_update, params[:decision_type_id])
      end
      
      if params[:review_committee_notes]
        @app = @offering.application_for_offerings.find(params[:id])
        @app.update(review_committee_notes: params[:review_committee_notes])
      end
      
      if params[:final_committee_notes]
        @app = @offering.application_for_offerings.find(params[:id])
        @app.update(final_committee_notes: params[:final_committee_notes])
      end
      
      if params[:requested_quarter] || params[:amount_requested] || params[:amount_awarded]
        @app = @offering.application_for_offerings.find(params[:id])
        
        for id,quarter in params[:requested_quarter]
          @app.awards.find(id).update(requested_quarter_id: quarter)
        end
        
        for id,amount in params[:amount_requested]
          @app.awards.find(id).update(amount_requested: amount)
        end
        
        for id,amount in params[:amount_awarded]
          @app.awards.find(id).update(amount_awarded: amount)
        end
        flash[:notice] = "Successfully updated for award quarter, amount requested, and amount awarded for #{@app.firstname_first}"

        @updated_apps << @app
      end
    
      respond_to do |format|
        format.html {
          if @committee_mode
            @apps ||= @offering.application_for_offerings.joins(:application_review_decision_type).where("application_review_decision_types.yes_option =?", true)
            @apps = @apps.sort_by{|x| (x.weighted_combined_score if x.weighted_combined_score > 0) || -1 }.reverse
            @max_number_of_scores = 4
            @cutoff = 1000 if @cutoff.nil?
          else
            @apps ||= @offering.application_for_offerings.reject{|a| a.reviewers.empty?}.sort_by{|a| a.average_score.to_s=="NaN" ? 0.0 : a.average_score}.reverse
            @max_number_of_scores ||= @apps.collect{|a| a.reviewers.size}.max
            @cutoff = 1000 if @cutoff.nil?
          end
        }
        format.js
      end
    end

    def dean_approve      
      @offerings = current_user.offerings_with_approval_access
      if request.post?
        params[:select].each do |app_id, attributes|
          app = ApplicationForOffering.find(app_id)
          app.dean_approve_awards(@current_user) if params[:commit]
          @offering = app.offering
        end
        flash[:notice] = "Saved approvals successfully. Thank you."
        redirect_to_action = params[:redirect_to_action] || "dean_approve"
        redirect_to :action => redirect_to_action
      end
    end

    def finaid_approve      
      @offerings = current_user.offerings_with_financial_aid_approval_access
      if request.post?
        params[:award].each do |award_id, attributes|
          award = ApplicationAward.find(award_id)
          award.update(award_params(attributes))
          award.application_for_offering.set_status "awaiting_disbursement" if params[:commit]
          award.application_for_offering.update(financial_aid_approved_at: Time.now) if params[:commit]
          @offering = award.application_for_offering.offering
        end
        EmailContact.log @offering.disbersement_approver.person.id, 
                        ApplyMailer.templated_message(@offering.disbersement_approver.person, 
                        EmailTemplate.find_by_name("disbersement approval request"), 
                        @offering.disbersement_approver.person.email, 
                        "http://#{Rails.configuration.constants["base_url_host"]}/admin/apply/disberse").deliver_now if params[:commit]
        flash[:notice] = "Saved financial aid eligibility approvals. Thank you."
        redirect_to_action = params[:redirect_to_action] || "finaid_approve"
        redirect_to :action => redirect_to_action
      end
    end

    def disberse      
      @offerings = current_user.offerings_with_disbersement_approval_access
      if request.post?
        params[:award].each do |award_id, attributes|
          award = ApplicationAward.find(award_id)
          award.update(award_params(attributes))
          award.application_for_offering.set_status "finalized" if params[:commit]
          award.application_for_offering.update(disbursed_at: Time.now) if params[:commit]
          @offering = award.application_for_offering.offering
        end
        flash[:notice] = "Saved disbursement information. Thank you."
        #redirect_to_action = params[:redirect_to_action] || "disberse"
        #redirect_to :action => redirect_to_action
      end
      
      respond_to do |format|
        format.html
        # format.xls { render :action => 'disberse', :layout => 'basic' } # disberse.xls.erb
      end
    end

    def invited_guests      
      @invited_guests = @confirmers.collect(&:guests).flatten.compact
      @not_mailed = @invited_guests.select{ |g| !g.invitation_mailed? }
      @mailed = @invited_guests.select{ |g| g.invitation_mailed? }.sort_by(&:invitation_mailed_at)
    end

    def nominated_mentors      
      @nominees = {}
      @offering.mentor_types.each{|t| @nominees[t.application_mentor_type] = {}}
      for nominator in @confirmers.reject{|c| c.nominated_mentor.nil? }
        mentor = nominator.nominated_mentor
        if mentor.person
          if @nominees[mentor.mentor_type][mentor.person].nil?
            @nominees[mentor.mentor_type][mentor.person] = [nominator]
          else
            @nominees[mentor.mentor_type][mentor.person] << nominator
          end
        end
      end
      @nominees.sort{|x,y| x.size <=> y.size }
      respond_to do |format|
        format.html # nominated_mentors.html.erb
        format.xlsx { render xlsx: 'nominated_mentors'} 
      end
    end
  
    def theme_responses
      # session[:breadcrumbs].add(@offering.theme_response_title || "Theme Responses")
      @theme_responders = @confirmers.reject{|c| c.theme_response.blank? }
      @theme2_responders = @confirmers.reject{|c| c.theme_response2.blank? }
      respond_to do |format|
        format.html # theme_response.html.erb
        format.xlsx { render xlsx: 'theme_responses' }
      end
    end
    
    def proceedings_requests      
      @proceedings_requests = @confirmers.collect(&:requests_printed_program).flatten.compact
    end
    
    def special_requests      
      @special_requests = @offering.application_for_offerings.where(confirmed: 1).where.not(special_requests: ['',nil])
      
      respond_to do |format|
        format.html
        format.xlsx  { render xlsx: 'special_requests' }
      end
    end


  	protected
  
    def fetch_offering
        if params[:offering]
          @offering = Offering.find params[:offering]
          require_user_unit @offering.unit
        end
    end

    def fetch_apps
      @apps ||= @offering.application_for_offerings.sort_by(&:fullname)
    end

    # Retrieve all applications and group members for this offering who have confirmed.
    def fetch_confirmers
      @confirmers = @offering.application_for_offerings.where(confirmed: true).to_a
      @confirmers += @offering.application_group_members.where(confirmed: true ).to_a
      @confirmers.flatten! if @confirmers.any? { |element| element.is_a?(Array) }
    end

    def fatch_phase
      @phase = @offering.phases.find(params[:phase])
    end

    def fatch_task
      @task = @phase.tasks.find(params[:id])
    end

    private

    def award_params(attributes)
      attributes.permit(:amount_approved, :disbersement_type_id, :amount_approved_notes, :amount_approved_user_id, :disbersement_quarter_id, :amount_disbersed, :amount_disbersed_notes, :amount_disbersed_user_id)
    end

    def interview_time_params
      params.require(:offering_interview).permit(:location, :start_time, :notes)
    end

    def interview_timeblock_params
      params.require(:new_interview_timeblock).permit(:date, :start_time, :end_time)
    end
    	  
  end
  
  sidebar "Quick Access", except: [:scored_selection, :dean_approve, :finaid_approve, :disberse] do
    render "admin/apply/sidebar/quick_access"
  end 
  sidebar "Search Application", only: [:show, :manage, :awardees] do
    # h2 "<i class=mi>search</i>Application Search".html_safe
    render "admin/apply/sidebar/search"
  end
  sidebar "Task for this Phase", only: [:phase, :task, :edit_interview] do
    render "admin/apply/phases/tasks/sidebar/tasks" 
  end
  sidebar "Switch to this Phase", only: [:phase] do
    render "admin/apply/phases/sidebar/switch_to_phase"
  end



end