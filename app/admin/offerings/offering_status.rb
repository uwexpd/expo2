ActiveAdmin.register OfferingStatus, as: 'statuses' do
	belongs_to :offering
	batch_action :destroy, false
	config.filters = false
	config.sort_order = 'sequence_asc'
	
	permit_params :application_status_type_id, :public_title, :disallow_user_edits, :disallow_all_edits, :message, :sequence, :allow_application_edits, :allow_abstract_revisions, :allow_abstract_confirmation

	index title: 'Statuses & Automatic E-mails' do
      column :sequence
      column ('Private Title') {|status| link_to status.private_title, admin_offering_status_path(offering, status) }
      column :public_title
      column ('E-mails') {|status| status.emails.collect{|email| link_to(email.send_to, admin_offering_status_email_path(offering, status, email), :title => email.email_template.title)}.join(", ").html_safe rescue "<span class='red'>unknown template<span>".html_safe}
      actions
    end

    sidebar "Offering Settings", only: :index do
			render "admin/offerings/sidebar/settings", { offering: offering }
  	end
    sidebar 'Statuses', only: [:show, :edit] do
      render "admin/offerings/statuses/statuses", { offering: offering, offering_status: statuses }
    end

    show :title => proc{|status|status.private_title} do
      attributes_table do
				row ('Status / Private Title') {|status| status.private_title }
				row ('Public Title') {|status| status.public_title }
				row :sequence
				row :disallow_user_edits
				row :disallow_all_edits
				row ('Message') {|status| raw(status.message)}
      end
	    panel '' do
				div :class => 'content-block' do
					table_for statuses.emails do
		              column ('To') {|email| email.send_to.titleize }
		              column ('Template') {|email| link_to email.email_template.title, admin_offering_status_email_path(offering, statuses, email) rescue "<span class='red'>Unknown</span>".html_safe }
		              column 'Auto-send?', :auto_send
					  column ('Functions'){|email|
								span link_to '<span class="material-icons">visibility</span>'.html_safe, admin_offering_status_email_path(offering, statuses, email), class: 'action_icon'
								span link_to '<span class="material-icons">edit</span>'.html_safe, edit_admin_offering_status_email_path(offering, statuses, email), class: 'action_icon'
								span link_to '<span class="material-icons">delete</span>'.html_safe, admin_offering_status_email_path(offering, statuses, email), method: :delete, data: { confirm:'Are you sure?', :remote => true}, class: 'delete action_icon'
					         }
					end
					div link_to '<span class="material-icons md-20">add</span>Add New Email'.html_safe, new_admin_offering_status_email_path(offering, statuses), class: 'button add'
				end
	    end
    end

    form do |f|
      semantic_errors *f.object.errors.keys
      f.inputs do
				f.input :application_status_type_id, as: :select, collection: ApplicationStatusType.all.sort_by(&:name), prompt: true, input_html: { class: 'select2', style: 'width: 50%'}
				f.input :public_title, input_html: {style: 'width: 50%;'}
				f.input :disallow_user_edits, as: :boolean
				f.input :disallow_all_edits, as: :boolean
				f.input :message, input_html: {  class: "tinymce", rows: 15, style: "width:100%;" }
				f.input :sequence, as: :select, collection: 1..(offering.statuses.max.sequence+1 rescue 1)
				div 'Restrictions', class: 'label'
				f.input :allow_application_edits, as: :boolean, label: 'Allow user to edit application details'
				f.input :allow_abstract_revisions, as: :boolean, label: 'Allow user to submit a revised abstract'
				f.input :allow_abstract_confirmation, as: :boolean, label: 'Allow user to confirm minor abstract revisions'
      end
      f.actions
	  end

end