ActiveAdmin.register Student do 
actions :index, :show
batch_action :destroy, false
menu parent: 'Groups'

  index pagination_total: false do    
    column 'Name' do |student|
      link_to student.fullname, admin_student_path(student)
    end
    column :email
    column ('Created At') {|person| "#{time_ago_in_words person.created_at} ago"}
  end

  show do
    @student = student
    render "admin/students/student_header", { student: student, mode: :info }
    div :class => 'tabsview' do
      tabs do
         tab 'Student Info' do
            attributes_table title: 'Student Info' do
              row ('Class standing') {|student| student.sdb.class_standing_description(:show_upcoming_graduation => true) }
              row ('Major(s)') {|student| raw(student.sdb.majors_list(true, "<br>")) }
              row ('Minor(s)') {|student| raw(student.sdb.minors_list(true, "<br>")) }
              row ('Current credits') do |student|
                  span student.current_credits(Quarter.current_quarter)
                  span "(#{Quarter.current_quarter.title})", class: 'light smaller'
                  status_tag 'full-time', class: 'small' if student.full_time?(Quarter.current_quarter)
              end
              row ('Gpa') {|student| student.sdb.gpa}
              row ('Gender') do |student|
                span "#{student.sdb.gender}"
                span "(#{student.sws.pronouns})", class: 'light' if student.sws.pronouns
              end
              row ('Age') do |student| 
                span student.sdb.age
                span :class => 'minor warning' if student.sdb.age < 18
              end
              row ('Birthday') {|student| student.sdb.birth_date.to_s}
              row ('Local phone') do |student| 
                span "#{student.phone_formatted}"
                span "(input by student)", class: 'light smaller'
              end
              row :email
            end
         end
         
         tab "Applications (#{student.application_for_offerings.size})", id: 'online_applications' do
          panel 'Online Application History' do
            hr class: 'header'
            div :class => 'content-block' do              
              table_for student.application_for_offerings do |app|
                column ('Created At') {|app| app.created_at.to_s(:short_at_time12)}
                column ('Offering title') {|app| link_to app.offering.title, admin_apply_manage_path(app.offering) }
                column ('Application title') {|app| link_to (strip_tags(app.project_title) || "(no title)"), admin_offering_application_path(app.offering.id, app.id)} 
                column ('Status'){|app| app.current_status_name.titleize rescue "unknown" }
              end
            end
          end
         end

         # units = Unit.where(abbreviation: ['carlson', 'bothell'])
         community_engaged_placements = student.service_learning_placements
         # .where(unit_id: units.collect(&:id))
         tab "Community Engagement (#{community_engaged_placements.size})", id: 'community_engagement' do
            panel "Community Engagement History" do
              hr class: 'header'
              table_for community_engaged_placements do
                column ('Quarter'){|placement| placement.course.quarter.title}
                column ('Course'){|placement| placement.course.title}
                column ('Position'){|placement| raw(placement.position.title) + " at " + placement.position.organization.name rescue "error"}
                column ('Unit'){|placement| placement.position.unit.name}
                # column (''){|placement| placement.evaluation_submitted? ? "Evaluation" : "Submit Evaluation"}
              end              
              attributes_table title: 'Acknowledgement of Risk' do
                row ('Date of Birth'){|student| student.sdb.birth_date.to_s(:long)}
                row ('Electronic AOR'){|student| student.service_learning_risk_date.to_date.to_s(:long) rescue "<span class=light>None on file</span>".html_safe}
                row ('Paper AOR on file'){|student| student.service_learning_risk_paper_date.to_date.to_s(:long) rescue "<span class=light>None on file</span>".html_safe}
              end
              if student.pipeline_placements 
                attributes_table title: 'Acknowledgement of Risk' do
                end
              end

            end
         end
         # tab "Pipeline" do
         # end
         tab "Events (#{student.event_invites.size})", id: 'events' do
            panel "Events" do
              render "admin/students/tabs/events"
            end
         end
         # tab "Equipments" do
         # end
         tab "Notes (<span id='notes_count'>#{student.notes.size}</span>)".html_safe, id: "notes" do
           panel "Notes" do
             hr class: 'header'
             br
             render "admin/people/notes", {person: student}
           end
         end
         tab "Contact History (#{student.contact_histories.size})", id: 'contact_history' do
           panel "Contact History" do
              hr class: 'header'
              # render "admin/students/tabs/contact_history"   
              paginated_collection(student.contact_histories.page(params[:page]).per(20).order('id DESC'), params: {anchor: 'contact_history' }, download_links: false) do
                table_for(collection, sortable: false) do            
                  column('Date'){|contact| contact.updated_at}
                  column('From'){|contact| contact.email_from unless contact.email.nil?}
                  column('Subject'){|contact| contact.email.subject unless contact.email.nil?}
                  column('View'){|contact| link_to "View", admin_contact_history_path(contact), target: "_blank"}
                end
              end
           end
         end
         tab "Appointments (#{student.appointments.size})", id: 'appointments' do
            panel "Appointments" do
              render "admin/students/tabs/appointments"
            end
         end
         tab "Transcript", id: 'transcript' do
            panel "Transcript" do
              render partial: "admin/students/transcript", object: student # [TODO] Tune this page, cost 3 sec
           end
         end
      end
    end    
  end
  sidebar "Student Search", only: :show do
      
  end

  member_action :photo, :method => :get do
  	begin
  	  student_photo = StudentPhoto.find(params[:reg_id])
  	  file_path = student_photo.try(:image_path, params[:size])
      if file_path
        send_file file_path, :disposition => 'inline', :type => 'image/jpeg' # TODO :x_sendfile => true in production
      else
        send_default_photo(params[:size])
      end
    rescue ActiveResource::ResourceNotFound
      send_default_photo(params[:size])
    end    
  end  

  filter :firstname, as: :string
  filter :lastname, as: :string
  filter :email, as: :string

end