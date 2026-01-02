ActiveAdmin.register OfferingInterviewer, as: 'interviewer' do
  belongs_to :offering  
  menu false
  config.filters = false
  config.per_page = [30, 50, 100, 200]
  config.sort_order = 'id_desc'

  permit_params :person_id, :offering_id, :special_notes, :interview_times_email_sent_at, :committee_member_id

  index do
    selectable_column
  	column ('Interviewer Name'){|interviewer| link_to interviewer.person_name, admin_person_path(interviewer.person_id)}        
    column ('Email'){|interviewer| interviewer.person_record.email}
    column :special_notes
    actions
  end

  batch_action :send_emails, confirm: "Are you sure to send mass emails?" do |ids|
    members = []
    batch_action_collection.find(ids).each do |member|
      members << member if member
    end
    redirect_to admin_email_write_path("select[#{members.first.class.to_s}]": members)
  end

  sidebar "Quick Access", only: :index do
    render "admin/apply/sidebar/quick_access"
  end 

  form do |f|
  	semantic_errors *f.object.errors.keys
  	inputs do      
  	  # f.input :person_id, as: :select,
      #   input_html: {
      #     class: "ajax-person-select",
      #     data: { url: search_admin_people_path }
      #   }
      f.input :person_id, label: 'Person ID', input_html: {style: 'width:25%;'}, hint: "Please use EXPO Person ID from #{link_to 'Find Person by Name or Email.', admin_people_path, target: '_blank'}".html_safe
      f.input :offering,  as: :select, required: true, input_html: {class: 'select2'}
      input :special_notes, input_html: { class: "tinymce", rows: 5}      
      actions
    end
  end


end