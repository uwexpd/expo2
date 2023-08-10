ActiveAdmin.register ApplicationForOffering, as: 'application' do
  belongs_to :offering
  actions :all, :except => [:destroy]
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  config.per_page = [20, 50, 100]
  menu false

  controller do
    before_action :fetch_offering, :except => [ :new, :create ]

    def update
      @app = ApplicationForOffering.find params[:id]
      anchor = params[:section] if params[:section]
      if params['application_for_offering']
        unless params['application_for_offering']['new_status'].blank?
          @app.set_status(params['application_for_offering']['new_status'], false, {:force => true, :note => params['application_for_offering']['new_status_note']}) 
          params['application_for_offering'].delete('new_status')
          params['application_for_offering'].delete('new_status_note')
          @update_application_status = true
        else
          params['application_for_offering'].delete('new_status') if params['application_for_offering']['new_status']
        end
        @app.add_reviewer params['application_for_offering']['new_reviewer'] unless params['application_for_offering']['new_reviewer'].blank?
        if params['application_for_offering']['special_notes']
          @app.update_attribute('special_notes', params['application_for_offering']['special_notes'])
          flash[:notice] = "Application notes saved."
          anchor = "review_committee"
        end
        if @app.update_attributes(app_params)
          flash[:notice] = "Application changes saved."
        end
      end
      respond_to do |format|
        format.html { redirect_to :action => 'show', :id => @app, :anchor => anchor }
        format.js
      end
    end

    protected
    
    def fetch_offering
      if params[:offering_id]
        @offering = Offering.find params[:offering_id]
        require_user_unit @offering.unit
      end
    end

    private
    
    def app_params
      params.require(:application_for_offering).permit! if params[:application_for_offering]   
    end    

  end

  # scope "test", defalut: true do |application|
  #   application.where(offering_id: 702)
  # end

  # controller do
  #   def scoped_collection
  #     # app_ids = Offering.find(params["offering_id"]).application_for_offerings.collect(&:id)
  #     # logger.debug("Debug => #{app_ids}")
  #     super.where(offering_id: params["offering_id"])
  #   end
  # end

  index do
    column :id
    # column 'Student Name' do |app|
    #   p link_to app.person.lastname_first, admin_student_path(app.person)
    #   p app.person.email rescue "Unknown"
    # end
    #column ('Project Tiitle') {|app| link_to app.project_title.blank? ? "View Application" : strip_tags(app.project_title), admin_offering_application_path(app.offering, app) }
    # column ('Current Status') {|app| raw(print_status(app)) }
    # actions
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
              render "question_review", { pages: application.pages.reject{|p|p.hide_in_admin_view?}, application: application }  # [TODO] tune this page, cost 3 sec
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
         tab "#{@offering.mentor_title.pluralize} (#{application.mentors.size})", id: 'mentor_letter' do
            panel "#{@offering.mentor_title.pluralize}" do
              render "mentor_letter", {admin_view: true}
            end
         end
         tab 'Review', id: 'review' do
           panel 'Review' do
              render "review_committee" # [TODO] Need to tune this page...cost almost 5 seconds
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

  sidebar "Student Search", only: :show do
      
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    inputs "#{application.fullname} - #{application.id}" do
      h1 "Under development"
      # input :offering_id
      # input :person_id
    end
    actions
  end

end 