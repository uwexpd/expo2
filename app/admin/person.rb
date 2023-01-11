ActiveAdmin.register Person do
  actions :all, :except => [:destroy]
  batch_action :destroy, false
  config.sort_order = 'created_at_desc'
  menu :priority => 5
  menu parent: 'Groups'
  
  permit_params :firstname, :lastname, :email, :salutation, :title, :organization, :phone, :box_no, :address1, :address2, :address3, :city, :state, :zip
  
  index pagination_total: false do
    column 'Name' do |person|
      link_to person.fullname, admin_person_path(person)
    end
    column :email
    column ('Created At') {|person| "#{time_ago_in_words person.created_at} ago"}
    actions
  end
  
  show do
    tabs do
         tab 'Person Info' do
            attributes_table do
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
         tab "Users (#{person.users.size})" do
           panel 'User Accounts' do
              table_for person.users do 
                 column 'Username' do |user|
                   span link_to user.login, admin_user_path(user)
                   span '@u.washington.edu', :class => 'light small' if user.is_a? PubcookieUser
                   status_tag 'admin', class: 'admin small' if user.admin?
                 end
                 column ('Person') {|user| link_to user.person.fullname, admin_person_path(user.person) }
                 column ('Last Login') {|user| "#{time_ago_in_words user.logins.last.created_at} ago" rescue "<font class=grey>never</font>" }
              end
            end
         end
         tab "Mentor (#{person.application_mentors.size})" do
           panel 'Mentored Projects' do
              table_for person.application_mentors do
                   column 'Offerings' do |mentor|
                     mentor.application_for_offering.offering.title if mentor.application_for_offering
                   end
                   column 'Applications' do |mentor|
                     if mentor.application_for_offering
                       span mentor.application_for_offering.person.fullname
                       span ' ― '
                       span mentor.application_for_offering.project_title || '(no title)'
                     end
                   end
              end
           end
         end
         tab "Committees (#{person.committee_members.size})" do
            panel 'Committees' do
               table_for person.committee_members do
                  column ('Name') {|commitee_member| commitee_member.committee.try(:name)}
               end
            end           
         end
         tab "Reviews/Interviews" do
         end         
         tab "Instructors" do
         end
         tab "Organizations" do
         end
         tab "Equipments" do
         end
         tab "Notes" do
         end
         tab "Contact History" do
         end                  
    end    
  end
  sidebar "People Search", only: :show do
      
  end

  
  form do |f|
     f.semantic_errors *f.object.errors.keys
     f.inputs do
       f.input :salutation, as: :select, collection: %w( Mr. Mrs. Ms. Miss Professor Dr. Hon. Rev. ), :include_blank => 'Please select'
       f.input :firstname
       f.input :lastname
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
end