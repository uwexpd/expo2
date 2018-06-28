ActiveAdmin.register Student do 
actions :index, :show
batch_action :destroy, false
menu parent: 'People'

  index pagination_total: false do    
    column 'Name' do |student|
      link_to student.fullname, admin_student_path(student)
    end
    column :email
    column ('Created At') {|person| "#{time_ago_in_words person.created_at} ago"}
  end

  show do
    render "admin/students/student_header", { student: student, mode: :info } 
    div :class => 'tabsview' do
      tabs do
         tab 'Student Info' do
            attributes_table do
              row ('Class standing') {|student| student.sdb.class_standing_description(:show_upcoming_graduation => true) }
              row ('Major(s)') {|student| raw(student.sdb.majors_list(true, "<br>")) }
              row ('Minor(s)') {|student| raw(student.sdb.minors_list(true, "<br>")) }
              row ('Current credits') do |student|
                  span student.current_credits(Quarter.current_quarter)
                  span "(#{Quarter.current_quarter.title})", :class => 'light smaller'
                  status_tag 'full-time', class: 'ok small' if student.full_time?(Quarter.current_quarter)
              end
              row ('Gpa') {|student| student.sdb.gpa}
              row ('Gender') {|student| student.sdb.gender}
              row ('Age') do |student| 
                span student.sdb.age
                span :class => 'minor warning' if student.sdb.age < 18
              end
              row ('Birthday') {|student| student.sdb.birth_date}
              row ('Local phone') do |student| 
                span "#{student.phone_formatted}"
                span "(input by student)", :class => 'light smaller'
              end
              row :email
            end
         end
         
         tab "Applications (#{student.application_for_offerings.size})" do           
         end
         tab "Service Learning" do         
         end
         tab "Pipeline" do
         end         
         tab "Omsfa" do
         end
         tab "Events" do
         end
         tab "Equipments" do
         end
         tab "Notes" do
         end
         tab "Contact History" do
         end
         tab "Appointments" do
         end
         tab "Transcript" do
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

end