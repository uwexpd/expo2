ActiveAdmin.register Person do
  actions :all, :except => [:destroy]
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu :priority => 5
  menu parent: 'Groups'
  
  permit_params :firstname, :lastname, :email, :salutation, :title, :organization, :phone, :box_no, :address1, :address2, :address3, :city, :state, :zip, :fullname

  controller do  
    def note_params
      params.require(:note).permit(:note, :contact_type_id, :notable_type, :creator_name, :access_level)
    end
  end

  member_action :note, method: [:post, :put] do
    @person = Person.find(params[:id])
    @note = @person.notes.create(note_params)
    
    respond_to do |format|
      format.html { redirect_to admin_person_path(@person), anchor: "notes" }
      format.js
    end    
  end


  index pagination_total: false do
    column 'Name' do |person|
      link_to person.fullname, admin_person_path(person)      
    end
    column '' do |person|
      status_tag 'student', class: 'small' if person.type
    end
    column :email
    column ('Created At') {|person| "#{time_ago_in_words person.created_at} ago" rescue ""}
    actions
  end
  
  show do
    tabs do
         tab 'Person Info' do
            attributes_table title: 'Person Info', id: 'person' do
              row ('Expo Person ID') {|person| person.id }
              row ('Name') {|person| person.fullname }
              row :email
              row :title
              row :organization
              row :phone
              row :box_no
              row ('Address') {|person| text_node "#{person.address1} #{person.address2 unless person.address2.blank?} #{person.address3 unless person.address3.blank?} #{person.city unless person.city.blank?}#{', '+person.state unless person.state.blank?} #{person.zip unless person.zip.blank?}" }
            end
         end
         tab "Users (#{person.users.size})", id: 'users' do
           panel 'User Accounts' do
              table_for person.users do 
                 column 'Username' do |user|
                   span link_to user.login, admin_user_path(user)
                   span '@u.washington.edu', :class => 'light small' if user.is_a? PubcookieUser
                   status_tag 'admin', class: 'admin small' if user.admin?
                 end
                 column ('Person') {|user| link_to user.person.fullname, admin_person_path(user.person) }
                 column ('Last Login') {|user| "#{time_ago_in_words user.logins.last.created_at} ago" rescue "<font class=grey>never</font>".html_safe }
              end
            end
         end
         tab "Mentor (#{person.application_mentors.size})", id: 'mentor' do
           panel 'Mentored Projects' do
              table_for person.application_mentors.reverse do
                   column 'Offerings' do |mentor|
                     mentor.application_for_offering.offering.title if mentor.application_for_offering
                   end
                   column ('Applications') {|mentor| link_to mentor.application_for_offering.person.fullname + " ― " + (mentor.application_for_offering.stripped_project_title || '(no title)'), admin_offering_application_path(mentor.application_for_offering.offering, mentor.application_for_offering) if mentor.application_for_offering }
              end
           end
         end
         tab "Committees (#{person.committee_members.size})", id: 'committees' do
            panel 'Committees' do
               table_for person.committee_members do
                  column ('Name') {|commitee_member| link_to commitee_member.committee.name, admin_committee_path(commitee_member.committee) rescue "<span class='grey'>Unknown</span>".html_safe }
                  # [TODO] link to committee members page where can view the review history
                  # https://expo.uw.edu/expo/admin/committees/7/members/536
                  # column ('Review') {}
               end
            end           
         end
         tab "Interviews", id: 'interviews' do
            panel 'Interviews' do
              # This will pull too many reviewed apps. We can try pagination but still not ideal.
              # Let's move this to committees tab then link to committee member to view review history
              # h2 "Reviews"
              # person.committee_members.reverse.each do |committee_member|
              #   h3 {b committee_member.committee.name}
              #   table_for committee_member.applications_for_review do
              #     column ('Applicants'){|app| link_to app.firstname_first, admin_offering_application_path(app.offering.id, app.id) }
              #   end
              # end
              h2 "Interviews"
              person.offering_interviewers.reverse.each do |interview|
                h3 { b interview.offering.title}
                table_for interview.offering_interview_interviewers do        
                  column("Applicants") {|app_interview| link_to app_interview.applicant.firstname_first, admin_offering_application_path(app_interview.applicant.offering.id, app_interview.applicant.id) rescue "app_interview: #{app_interview.id}" }
                  column("Comments") {|app_interview| app_interview.comments rescue "#Error!"}
                end
              end
            end
         end
         tab "Instructors (#{person.service_learning_course_instructors.size})", id: 'instructor' do
            panel 'Courses Instructed' do 
              table_for person.service_learning_course_instructors.reverse do                
                  column ('Quarter') {|instrutor| instrutor.service_learning_course.quarter.title unless instrutor.service_learning_course.blank?}
                  column ('Unit') {|instrutor| instrutor.service_learning_course.unit.title unless instrutor.service_learning_course.blank?}
                  column ('Course') {|instrutor| instrutor.service_learning_course.title unless instrutor.service_learning_course.blank?}
              end
            end
         end
         tab "Organizations (#{person.organization_contacts.size})", id: 'organizations' do
           panel 'Organizations' do
             table_for person.organization_contacts do
               column('Current Organizations'){|contact| link_to contact.organization.name, admin_organization_path(contact.organization)}
               column('Units'){|contact| contact.units.collect(&:name).join("<br>").html_safe}
             end
             unless person.former_organization_contacts.blank?
               table_for person.former_organization_contacts do
                 column('Former Organization'){|contact| link_to contact.organization.name, admin_organization_path(contact.organization)}
                 column('Units'){|contact| contact.units.collect(&:name).join("<br>").html_safe}
               end
             end

           end
         end
         # tab "Equipments" do
         # end
         tab "Notes (<span id='notes_count'>#{person.notes.size}</span>)".html_safe, id: "notes" do
           panel "Notes" do
             render "notes", {person: person}
           end
         end
         tab "Contact History (#{person.contact_histories.size})", id: 'contact_history' do
           panel "Contact History" do
              paginated_collection(person.contact_histories.page(params[:page]).per(20).order('id DESC'), params: {anchor: 'contact_history' }, download_links: false) do
                table_for(collection, sortable: false) do            
                  column('Date'){|contact| link_to contact.updated_at.to_s(:long_time12),  admin_contact_history_path(contact), target: "_blank" }
                  column('From'){|contact| contact.email_from unless contact.email.nil?}
                  column('Subject'){|contact| contact.email.subject.force_encoding('UTF-8') unless contact.email.nil?}
                  column('View'){|contact| link_to "View", admin_contact_history_path(contact), target: "_blank" }
                end
              end
           end
         end
    end    
  end

  sidebar "People Search", only: :show do
      render "search_person"
  end
  
  form do |f|
     f.semantic_errors *f.object.errors.keys
     f.inputs do
       f.input :salutation, as: :select, collection: %w( Mr. Mrs. Ms. Miss Professor Dr. Hon. Rev. ), :include_blank => 'Please select'
       f.input :firstname
       f.input :lastname
       f.input :fullname
       f.input :title
       f.input :organization, label: 'Organization/Institution'
       f.input :email
       f.input :phone
       f.input :box_no
       f.input :address1, label: 'Address Line 1'
       f.input :address2, label: 'Address Line 2'
       f.input :address3, label: 'Address Line 3'
       f.input :city
       f.input :state
       f.input :zip
     end
     f.actions do
       f.action(:submit)
       f.cancel_link(admin_person_path(person))
     end
   end
   
  filter :email, as: :string
  filter :firstname, as: :string
  filter :lastname, as: :string
  # filter :student_no_eq, label: 'Student Number'
end