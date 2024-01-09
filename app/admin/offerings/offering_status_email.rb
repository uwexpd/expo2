ActiveAdmin.register OfferingStatusEmail, as: 'emails'  do	
	batch_action :destroy, false
	menu false
	config.filters = false

	permit_params :send_to, :email_template_id, :auto_send, :cc_to_feedback_person

	breadcrumb do
  	[
  		link_to('Expo', root_path),
  		link_to('Offerings',admin_offerings_path ),
  		link_to("#{controller.instance_variable_get(:@offering).title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}" ),
  		link_to('Statuses', admin_offering_statuses_path),  		
  		link_to("#{controller.instance_variable_get(:@status).private_title}", "/expo/admin/offerings/#{controller.instance_variable_get(:@offering).id}/statues/#{controller.instance_variable_get(:@status).id}" )
  	 ]
  end
    
	controller do
		nested_belongs_to :offering, :status
		before_action :fetch_status

		def destroy
			@email = @status.emails.find(params[:id])
			@email.destroy

		    respond_to do |format|
		      format.html {redirect_to(admin_offering_status_path(@offering, @status))}
		      format.js { render js: "$('.delete').bind('ajax:success', function() {$(this).closest('tr').fadeOut();});"}
			end
		end

		protected

		def fetch_status
			@offering = Offering.find params[:offering_id]
			@status = @offering.statuses.find params[:status_id]			
		end
	end

	index do
		column ('To') {|email| email.send_to.titleize }
        column ('Template') {|email| email.email_template.title }
		column :auto_send
		actions
	end

	sidebar 'Statuses', only: [:show, :edit] do
      render "admin/offerings/statuses/emails", { status: emails.offering_status, status_email: emails }
    end

	show :title => proc{|email| email.email_template.title } do 
      attributes_table do
      	row ('Recipient') {|email| email.send_to.titleize }
      	row ('Email Template') {|email| email.email_template.title rescue "<span class='red'>Unknown</span>".html_safe }
      	row :auto_send
      	row :cc_to_feedback_person      	      
      end
      render "admin/communicate/email_preview", { template: emails.email_template }
    end

    form do |f|
      semantic_errors *f.object.errors.keys
      f.inputs do
      	f.input :send_to, as: :select, collection: [['Applicant', 'applicant'],['Mentors', 'mentors'],['Staff', 'staff'],['Group Members', 'group_members']], input_html: { class: 'select2', style: 'width: 50%'}
      	f.input :email_template_id, as: :select, collection: EmailTemplate.all, input_html: { class: 'select2'} 
      	f.input :auto_send, as: :boolean
      	f.input :cc_to_feedback_person, as: :boolean      	
      end
      f.actions
	end

end