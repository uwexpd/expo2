ActiveAdmin.register ApplicationForOffering, as: 'applications' do
  belongs_to :offering  
  actions :all, :except => [:destroy]
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu false

  index do
  
  end

  show :title => proc{|app|app.person.fullname} do
    student = applications.person
    render "admin/applications/application_header", { app: applications, student: student}
    div :class => 'tabsview' do
      tabs do
         tab 'Student Info' do
            attributes_table do
             row ('Expo ID') do |app|
               link_to "#{student.class} #{student.id}", send("admin_#{student.class.to_s.underscore}_path", student)
             end
             row ('Class standing') {|app| student.class_standing_description(:show_upcoming_graduation => true) }
             row ('Major(s)') {|app| raw(student.majors_list(true, "<br>")) }
             if student.is_a?(Student)
               row ('Current credits') do |app|
                   span student.current_credits(app.offering.quarter_offered || Quarter.current_quarter)
                   span "(#{(app.offering.quarter_offered || Quarter.current_quarter).title})", class: 'light smaller'
                   status_tag 'full-time', class: 'small' if student.full_time?(app.offering.quarter_offered || Quarter.current_quarter)
               end
              end
              row ('Gpa') {|app| student.sdb.gpa rescue raw("<span class='empty'>Empty</span>")}
              row ('Gender') do |app|
               span student.gender.blank? ? raw("<span class='empty'>Empty</span>") : "#{student.gender}"
               span "(#{student.sws.pronouns})", class: 'light' if student.sws.pronouns rescue nil
              end
              row ('Age') do |app|
               span student.sdb.age rescue raw("<span class='empty'>Empty</span>")
              end
              row ('Birthday') {|app| student.sdb.birth_date.to_s rescue raw("<span class='empty'>Empty</span>")}
              row ('Email') {|app| student.email}
              # row ('Full History'){|app| link_to 'See full student history', admin_student_path(student)}
            end
         end
         unless applications.offering.other_award_types.empty?
	         tab 'Past Applications' do

	         end
	     end
         tab 'Application Details' do
           panel '' do
              pages = applications.pages.reject{|p|p.hide_in_admin_view?}
              pages.each do |page|
                h2 "#{page.offering_page.title}"
                render partial: "admin/applications/question_review",
                       collection: page.offering_page.questions,
                       locals: { app: applications }
              end
           end
         end

         tab 'Group Members' do

         end
         tab 'Transcript' do

         end
         tab "Essay & Files" do

         end
         tab 'Student Info' do

         end
         tab 'Student Info' do

         end
      end
    end
  end

  sidebar "Student Search", only: :show do
      
  end

end 