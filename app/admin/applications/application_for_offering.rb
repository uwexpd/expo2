ActiveAdmin.register ApplicationForOffering, as: 'application' do
  belongs_to :offering, optional: true
  includes :person, :offering, :current_application_status
  actions :all, :except => [:new, :destroy]
  batch_action :destroy, false
  config.per_page = [20, 50, 100]
  menu parent: 'Databases', priority: 10, label: "<i class='mi padding_right'>feed</i> Applications".html_safe
  # Disable default sorting so that scoped_collection sorting takes effect
  config.sort_order = ''

  scope 'All', :valid, default: true
  scope 'New', :new_status
  scope 'In Progress', :in_progress
  scope 'Submitted', :submitted
  scope :complete do |applications|
    applications.joins(current_application_status: :application_status_type).where(application_status_types: { name: 'complete' })
  end
  scope 'Awarded', :awarded, if: -> { params[:offering_id] && ApplicationForOffering.where(offering_id: params[:offering_id]).awarded.count > 0 }

  controller do
    before_action :fetch_application, :except => [ :new, :create ]

    def scoped_collection
      if params[:offering_id].present?
        ApplicationForOffering.where(offering_id: params[:offering_id]).valid.includes(:person).order('people.lastname asc, people.firstname asc')
      else
        ApplicationForOffering.order('application_for_offerings.created_at desc')
      end
    end

    def update
      anchor = params['section'] if params['section']
      update_application_status = false
      if params['application']
        unless params['application']['new_status'].blank?
          @app.set_status(params['application']['new_status'], false, {:force => true, :note => params['application']['new_status_note']}) 
          params['application'].delete('new_status')
          params['application'].delete('new_status_note')
          update_application_status = true
          flash[:notice] = "Application status was updated."
        else
          params['application'].delete('new_status') if params['application']['new_status']
        end

        @app.add_reviewer params['application']['new_reviewer'] unless params['application']['new_reviewer'].blank?

        if !update_application_status && @app.update(app_params)
          flash[:notice] = "Application changes saved."
        end        
      end
      
      if params['resend_group_member']
          if @app.group_members.find(params['resend_group_member']).send_validation_email
            flash[:notice] = "Successfully re-sent verification e-mail."
          else
            flash[:alert] = "Could not send verification e-mail."
          end
          anchor = "group_members"
      end

      # update the application's attributes
      if application_params
         if @app.update(application_params)
            anchor = "application_review"
            flash[:notice] = "Successfully updated applicaiton."
         else
            flash[:alert] = "Something went wrong. Please try again later."
         end
      end

      session[:return_to_after_email_queue] = request.referer
      redirect_to admin_email_queues_path and return if EmailQueue.messages_waiting?

      respond_to do |format|
        format.html { redirect_to :action => 'show', :id => @app, :anchor => anchor }
        format.js
      end
    end

    def composite_report
      if params[:include]
        parts = []
        params[:include].each do |part,value|
          parts << part.to_sym
        end
        file = @app.composite_report.pdf(parts)
        unless file.is_a?(String)
          flash[:alert] = "Sorry, but there was an error creating the file. (#{file.inspect})"
          redirect_to action: "show", id: params[:id] and return
        end
        send_file file, disposition: 'attachment', type: 'application/pdf' unless file.nil?
      else
        flash[:alert] = "You have to identify which parts of the application to include."
        redirect_to action: "show", id: params[:id] and return
      end
    end

    protected
    
    def fetch_application
      # if params[:offering_id]
      #   @offering = Offering.find params[:offering_id]
      # end
      if params[:id]
        @app = ApplicationForOffering.find params[:id]
        @offering = @app.offering
        require_user_unit @offering.unit
      end
    end

    private
    
    def app_params
      params.require(:application).permit! if params['application']
    end

    def application_params
      params.require(:user_application).permit! if params[:user_application]
    end

  end

  batch_action :email_primary_applicants, confirm: "Are you sure to send mass emails to primary applicants?" do |ids|
    applicants = []
    batch_action_collection.find(ids).each do |app|
      applicants << app if app
    end
    redirect_to admin_email_write_path("select[#{applicants.first.class.to_s}]": applicants)
  end

  batch_action :email_mentors, confirm: "Are you sure to send mass emails to mentors" do |ids|
    mentors = []
    batch_action_collection.find(ids).each do |app|
      app.mentors.each{|mentor| mentors << mentor } if app
    end
    redirect_to admin_email_write_path("select[#{mentors.first.class.to_s}]": mentors)
  end

  batch_action :email_group_members, confirm: "Are you sure to send mass emails to mentors" do |ids|
    group_members = []
    batch_action_collection.find(ids).each do |app|
      app.group_members.each{|member| group_members << member } if app      
    end
    redirect_to admin_email_write_path("select[#{group_members.first.class.to_s}]": group_members)
  end

  index do
    selectable_column unless params[:offering_id].blank?
    column 'Student Name' do |app|
      text_node link_to app.person.lastname_first, app.person.is_a?(Student) ? admin_student_path(app.person) : admin_person_path(app.person)
      br
      span("#{app.person.email rescue Unknown}", class: 'caption')
    end
    if params[:offering_id].blank?
      column ('Offering') {|app| link_to app.offering.title, admin_offering_path(app.offering) }
    end
    column ('Project Title') {|app| link_to app.project_title.blank? ? "View Application" : highlight(strip_tags(app.project_title), params.dig(:q, :project_title_contains)), admin_offering_application_path(app.offering, app) }
    column ('Current Status') {|app| raw(print_status(app)) }
    actions
  end

  show :title => proc{|app|app.person.fullname} do
    @app = application
    @student = application.person
    @offering = application.offering
    render "application_header", { app: application, student: @student}
    div :class => 'tabsview' do
      tabs do
         tab 'Student Info', id: 'student_info' do
            attributes_table title: 'Student Information' do             
             row ('Expo ID') do |app|
               link_to "#{@student.class} #{@student.id}", send("admin_#{@student.class.to_s.underscore}_path", @student)
             end
             row ('Class standing') {|app| @student.class_standing_description(:show_upcoming_graduation => true) }
             row ('Major(s)') {|app| raw(@student.majors_list(true, "<br>")) }
             if @student.is_a?(Student)
               row ('Current credits') do |app|
                   span @student.current_credits(@offering.quarter_offered || Quarter.current_quarter)
                   span "(#{(app.offering.quarter_offered || Quarter.current_quarter).title})", class: 'light smaller'
                   status_tag 'full-time', class: 'small' if @student.full_time?(app.offering.quarter_offered || Quarter.current_quarter)
               end
              end
              row ('Gpa') {|app| @student.sdb.gpa rescue raw("<span class='empty'>Empty</span>")}
              row ('Gender') do |app|
               span @student.gender.blank? ? raw("<span class='empty'>Empty</span>") : "#{@student.gender}"
               span "(#{@student.sws.pronouns})", class: 'light' if @student.sws.pronouns rescue nil
              end
              row ('Age') do |app|
               span @student.sdb.age rescue raw("<span class='empty'>Empty</span>")
              end
              row ('Birthday') {|app| @student.sdb.birth_date.to_s rescue raw("<span class='empty'>Empty</span>")}
              row ('Email') {|app| @student.email}
              # row ('Full History'){|app| link_to 'See full student history', admin_student_path(student)}
            end            
         end
         unless application.past_applications.empty?
	         tab 'Past Applications' do
              panel 'Past Applications' do
                render "past_applications", {application: application, audience: :admin}
              end
	         end
	       end
         tab 'Application Details', id: 'application_review' do
           panel 'Application Details' do
              render "question_review"  # [TODO] tune this page, cost 3 sec
           end
         end
         if @offering.uses_group_members?
           tab "Group Members (#{application.group_members.size})", id: 'group_members' do
              panel 'Group Members' do
                render "group_members"
              end
           end 
         end
         tab 'Transcript' do
           panel 'Student Transcript' do
              render "transcript", {admin_view: true} # [TODO] Tune this page, cost 3 sec
           end
         end
         tab "Essay & Files (#{application.files.size})", id: 'essay' do
            panel 'Essay & Files' do
              render "essay", {admin_view: true}
            end
         end
         unless application.awards.empty?
           tab "Award Quarters (#{application.awards.valid.size})", id: 'awards' do
             panel 'Award Quarters' do
              render "awards"
             end
           end
         end
         if @offering.uses_mentors?
           tab "#{@offering.mentor_title.pluralize} (#{application.mentors.size})", id: 'mentor_letter' do
              panel "#{@offering.mentor_title.pluralize}" do
                render "mentor_letter", {admin_view: true}
              end
           end
         end
         tab 'Review', id: 'review' do
           panel 'Review' do
              render "review_committee"
           end
         end
         if @offering.uses_interviews?
            tab 'Interview' do
             panel 'Interview' do
                render "interview"
             end
            end
         end
         unless @offering.sessions.empty?
           tab 'Session', id: 'session' do
              panel 'Session' do
                render "session"
             end 
           end
         end
         tab 'Application History', id: 'history' do
            panel 'Application History' do
              render "history"
            end
         end
         tab 'Notes & Feedback', id: 'notes' do
            panel 'Special Notes' do
              render "notes"
            end
         end
      end
    end
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    #"#{application.fullname unless object.new_record?} - #{application.id unless object.new_record?}"
    @app_pages = []
    @app = f.object
    @app.pages.each do |page|
      question_types = page.offering_page.questions.collect(&:display_as).uniq.to_set
      attribute_types = page.offering_page.questions.collect(&:attribute_to_update).uniq.to_set
      unless (!question_types.include?("radio_logic_toggle") && ["files","mentors"].any? {|type| question_types.include?(type) })
        @app_pages << page
      end
    end
    
    tabs do
      @app_pages.each do |app_page|
        page_title = app_page.offering_page.title
        tab "#{page_title}" do
          f.inputs "#{page_title}" do
            render 'admin/applications/edit_application_details', { f: f, app_page: app_page, app: @app }
          end
        end
      end
    end
    f.actions do      
      f.action :submit, label: 'Update Application', class: 'button'
      f.cancel_link :back #admin_offering_application_path(offering, @app)
    end
    
  end

  # proc {"Applicant Search for #{application.offering.title}"} is not working
  sidebar "Applicant Search", only: :show do
      render "search_applicant", {offering_id: application.offering.id}
  end

  filter :person_firstname, as: :string
  filter :person_lastname, as: :string
  filter :id, label: 'Application ID'  
  filter :offering, as: :select, collection: Offering.order('id DESC'), input_html: { class: "select2", multiple: 'multiple'}, if: proc { @offering.blank? }
  filter :project_title, as: :string
  filter :project_description, as: :string
  filter :current_application_status_application_status_type_id, label: 'Current status', as: :select, collection: proc { @offering.blank? ? ApplicationStatusType.order('name asc').map{|a|[a.name_pretty, a.id]} : @offering.statuses.map{|s|[s.application_status_title, s.application_status_type.id]} }, input_html: { class: "select2", multiple: 'multiple'}

end 