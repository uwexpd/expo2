ActiveAdmin.register_page "Email" do  
  menu false

  controller do
  	before_action :get_recipients, :except => [ :apply_template ]

  	
  	def write
  		# logger.debug "Debug => #{@recipients.inspect}"

  	end

  	def queue
  		if params[:update_email_template]
        @template = EmailTemplate.find params[:email][:template_id]
        @template.update(body: params[:email][:body])
      end
      if params[:create_email_template] && params[:new_email_template_name]
        @email_template = EmailTemplate.new(:name => params[:new_email_template_name], 
                                        :body => params[:email][:body], 
                                        :subject => params[:email][:subject],
                                        :from => params[:email][:from])
        unless @email_template.save
          # session[:breadcrumbs].add "Compose Message"
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
        logger.debug "Debug before queued => #{template.inspect}"
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

  	protected

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
            @recipients << recipients
          end
        end
        @recipients.flatten!
        @recipients.compact!
        @recipients.uniq!

  	end
	  
  end

end