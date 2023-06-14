ActiveAdmin.register ApplicationForOffering, as: 'application' do
  belongs_to :offering  
  actions :all, :except => [:destroy]
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu false

  index do
  
  end

  show :title => proc{|app|app.person.fullname} do
    @app = application
    @student = application.person
    @offering = application.offering    
    render "application_header", { app: application, student: @student}
    div :class => 'tabsview' do
      tabs do
         tab 'Student Info' do
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
         tab 'Application Details' do
           panel 'Application Details' do
              render "question_review", { pages: application.pages.reject{|p|p.hide_in_admin_view?}, application: application }              
           end
         end
         if @offering.uses_group_members?
           tab "Group Members (#{application.group_members.size})" do
              panel 'Group Members' do
                render "group_members"
              end
           end 
         end
         tab 'Transcript' do
           panel 'Student Transcript' do
              render "transcript", {admin_view: true}
           end
         end
         tab "Essay & Files (#{application.files.size})" do
            panel 'Essay & Files' do
              render "essay", {admin_view: true}
            end
         end
         unless application.awards.empty?
           tab "Award Quarters (#{application.awards.valid.size})" do
             panel 'Award Quarters' do
              render "awards"
             end
           end
         end
         tab "#{@offering.mentor_title.pluralize} (#{application.mentors.size})" do
            panel "#{@offering.mentor_title.pluralize}" do
              render "mentor_letter", {admin_view: true}
            end
         end
         tab 'Review' do
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
           tab 'Session' do
              panel 'Session' do
                render "session"
             end 
           end
         end
         tab 'Application History' do
            panel 'Application History' do
              render "history"
            end
         end
         tab 'Notes & Feedback' do
            panel 'Special Notes' do
              render "notes"
            end
         end
      end
    end
  end

  sidebar "Student Search", only: :show do
      
  end

end 