ActiveAdmin.register_page "Email" do  
  menu false

  controller do
  	before_action :get_recipients, :except => [ :apply_template ]
  	
  	def write
  		# logger.debug "Debug => #{@recipients.inspect}"
      @recipient_sample = @recipients.try(:first)
      @recipient_sample_num = 0

  	end

  	def queue
  		if params[:update_email_template]        
        @template = EmailTemplate.find params[:email][:template_id]
        @template.update(body: params[:email][:body])
      end
      if params[:create_email_template] && params[:new_email_template_name]        
        @email_template = EmailTemplate.new(name: params[:new_email_template_name], 
                                        body: params[:email][:body], 
                                        subject: params[:email][:subject],
                                        from: params[:email][:from])        
        unless @email_template.save          
          return render :action => "write"
        end
      end
      @recipients.each do |recipient|
        person_id = recipient.is_a?(Person) ? recipient.id : recipient.person.id rescue nil        
        command_after_delivery = nil
        email_from = params[:email][:from]
        email_subject = params[:email][:subject]
        email_body = params[:email][:body]

        if params[:html_format].nil? || params[:html_format] == false
          template = TemplateMailer.text_message(recipient, email_from, email_subject, email_body).message
        else          
          template = TemplateMailer.html_message(recipient, email_from, email_subject, email_body).message
        end        
        EmailQueue.queue(person_id, template, nil, command_after_delivery, nil, recipient)
      end
      flash[:notice] = "Successfully queued #{@recipients.size} messages."
      return redirect_to admin_email_queues_path if EmailQueue.messages_waiting?
      redirect_to request.referer
  	end

    def apply_template
      @email_template = EmailTemplate.find(params[:email_template_id]) unless params[:email_template_id].blank?
      respond_to do |format|
        format.js
      end
    end

    def resample_placeholder_codes
      @recipient_sample_num = params[:new_sample_num].to_i rescue 0
      @recipient_sample = @recipients[@recipient_sample_num] rescue @recipients.first rescue nil
      respond_to do |format|
        format.html { render :write }
        format.js
      end
    end

    def sample_preview
      @recipient_sample_num = params[:current_sample_num].to_i rescue 0
      @recipient_sample = @recipients[@recipient_sample_num] rescue @recipients.first rescue nil
      respond_to do |format|
        format.html { render :write }
        format.js
      end
    end

  	protected

    # Extracts an array of recipient objects. These objects MUST have a "person" attribute or be a Person, otherwise they won't be added.
    # Format:  "select"=>{"ApplicationForOffering"=>{"127114"=>"1", "122739"=>"1", "124292"=>"1"}}
  	def get_recipients      
      unless params[:select]
          flash[:alert] = "You must select at least one recipient to send the message to."
          redirect_back(fallback_location: root_path)
      end
      @recipients = []
      params[:select].each do |obj_type,obj_hash|
        obj_hash = JSON.parse(obj_hash) if obj_hash.is_a? String
        obj_hash.each do |obj_id,val|
          obj = obj_type.constantize.find(obj_id)

          unless params[:group_variant].blank?
            recipients = obj.instance_eval(params[:group_variant])
          else
            recipients =  case obj.class.to_s
                          when "OrganizationQuarter"      then obj.organization.contacts
                          when "Organization"             then obj.contacts
                          when "School"                   then obj.contacts
                          when "ServiceLearningCourse"    then obj.instructors
                          when "CommitteeMemberMeeting"   then obj.committee_member
                          when "CommitteeMemberQuarter"   then obj.committee_member
                          when "EventStaffPositionShift"  then obj.staffs
                          when "Population"               then obj.objects
                          when "PopulationGroup"          then obj.objects
                          else obj
                          end
          end
          # logger.debug "DEBUG recipients => #{recipients.inspect}"
          unless params[:recipient_variant].blank?
             if params[:recipient_variant] == "required_mentors"
               recipients = [recipients] unless recipients.is_a?(Array)
               recipients.each{ |r| @recipients << r.mentors.reject(&:approved?).select{|m| m.primary || m.meets_minimum_qualification?} }
             else
               if obj_type == "ServiceLearningCourse" && recipients.blank?
                   # Handle no instructors for service learning course
                  @recipients << obj.instance_eval((params[:recipient_variant].split(".").second))
               else
                 recipients = [recipients] unless recipients.is_a?(Array)
                 recipients.each{ |r| @recipients << r.instance_eval(params[:recipient_variant]) }
               end
             end
          else
            @recipients << recipients
          end
        end
      end
      @recipients.flatten!
      @recipients.compact!
      @recipients.uniq!
  	end
	  
  end

  sidebar "Placeholder Codes", only: :write do
    render "admin/email/placeholder_codes"
  end

end