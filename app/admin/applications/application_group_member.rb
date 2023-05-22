ActiveAdmin.register ApplicationGroupMember, as: 'group_member' do  
  menu false  
  config.filters = false
  config.sort_order = 'created_at_asc'

  permit_params :person_id, :verified, :firstname, :lastname, :email, :uw_student, :confirmed, :nominated_mentor_id, :nominated_mentor_explanation, :theme_response, :theme_response2, :requests_printed_program

  controller do
	nested_belongs_to :offering, :application
	before_action :fetch_app

	def destroy
		@group_member = @app.group_members.find(params[:id])
		@group_member.destroy

	    respond_to do |format|
	      format.html { redirect_to(admin_offering_application_group_members_path(@offering, @app)) }
	      format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut();});"}
		end
	end

	protected

	def fetch_app
		@offering = Offering.find params[:offering_id]
		@app = ApplicationForOffering.find params[:application_id]
	end
  end

  index do
	column ('Name') {|member| link_to member.lastname_first, admin_offering_application_group_member_path(member.offering, member.app, member,id)}
	column ('Institution') {|member| member.person.institution_name if member.person}
    column ('Verified?') {|member| member.verified?}
    column ('Confirmed?') {|member| member.confirmed?}
    actions
  end

  show do
  	attributes_table do
	    row :firstname        
	    row :lastname
	    row :uw_student
	    row :email
	    row 'Verified' do |member| 
	       status_tag member.verified?
	       span " Verification e-mail sent #{relative_timestamp(member.validation_email_sent_at)}"
        end	    
	    row :confirmed
	    row ('Nominated Mentor') {|member| raw(member.nominated_mentor.fullname + '<br>' + "<small>#{member.nominated_mentor_explanation}</small>") if member.nominated_mentor} 
	    row :theme_response
	    row :theme_response2
	    row 'Printed proceedings?', &:requests_printed_program
	    row ('Full Name') {|member| member.person.fullname rescue 'unknown'}
	    row ('Email') {|member| member.person.email rescue 'unknown'}
	    row ('Phone') {|member| member.person.phone rescue 'unknown'}
	    row ('Institution') {|member| member.person.institution rescue 'unknown'}
	    row ('Majors') {|member| member.person.majors_list rescue 'unknown'}
	    row ('Class') {|member| member.person.class_standing_description rescue 'unknown'}
	    row ('Scholarships') {|member| member.person.awards_list rescue 'unknown'}
	end  	
  end

  form do |f|
	f.semantic_errors *f.object.errors.keys
	inputs do
	  input :person_id, input_html: { style: 'width: 30%'}
	  input :verified, as: :boolean
      input :firstname, input_html: { style: 'width: 30%'}
      input :lastname, input_html: { style: 'width: 30%'}   
      input :email, input_html: { style: 'width: 30%'}
      input :uw_student      
      input :confirmed, as: :boolean
      input :nominated_mentor_id, as: :select, collection: group_member.app.mentors.map{|m| [m.fullname, m.id] }, include_blank: true
      input :nominated_mentor_explanation, input_html: { :rows => 5, :style => "width:100%;" }
      input :theme_response, input_html: { :rows => 4, :style => "width:100%;" }
      input :theme_response2, input_html: { :rows => 4, :style => "width:100%;" }
      input :requests_printed_program, label: 'Printed Proceedings?'      
    end
    actions

  end

end