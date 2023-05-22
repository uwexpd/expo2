ActiveAdmin.register ApplicationMentor, as: 'mentor' do 
  # belongs_to :application_for_offering
  actions :all, :except => [:destroy]
  batch_action :destroy, false
  config.per_page = [30, 50, 100, 200]
  config.sort_order = 'created_at_desc'
  menu parent: 'Groups'

  scope :with_name, default: true

  permit_params :primary, :waive_access_review_right, :firstname, :lastname, :email, :email_confirmation, :application_mentor_type_id, :academic_department, :approval_response, :approval_comments, :approval_at, :title, :relationship

  index do
  	column ('Name') {|mentor| link_to mentor.fullname, admin_mentor_path(mentor)}
    # column 'Person Record' do |mentor|
    #   mentor.person_id.nil? ? mentor.fullname : link_to(mentor.fullname, admin_person_path(mentor))
    # end
    column ('Email') {|mentor| mentor.email }
    column ('Offering') {|mentor| link_to(mentor.offering.title, admin_offering_path(mentor.offering)) if mentor.offering}
    column ('Application') {|mentor| link_to(mentor.application_for_offering.stripped_project_title || "(no title)", admin_offering_application_path(mentor.offering.id, mentor.application_for_offering_id))}
    # column ('Created At') {|mentor| "#{time_ago_in_words mentor.created_at} ago"}
    actions
  end

  show do
  	attributes_table do
  		row :id  		
  		row ('Fullname') do |mentor| 
                span mentor.person_id.nil? ? mentor.fullname : link_to(mentor.fullname, admin_person_path(mentor))
                span 'Primary Mentor', :class => 'outline tag' if mentor.primary?
              end
  		row :email
  		row :application_for_offering
  		row :title
  		row :relationship
  		row :mentor_type
  		row :waive_access_review_right
  		row :academic_department
  		row :approval_response
  		row :approval_comments
  		row (:approval_at) {|mentor| mentor.approval_at.to_s(:short_at_time12) if mentor.approval_at}	  		
  		row (:created_at) {|mentor| mentor.created_at.to_s(:short_at_time12)}
  	end
  end

  form do |f|
    semantic_errors *f.object.errors.keys
    f.inputs do
    	f.input :primary, as: :boolean
    	f.input :firstname, :input_html => { :style => 'width:50%;' }
    	f.input :lastname, :input_html => { :style => 'width:50%;' }    	
    	f.input :email, :input_html => { :style => 'width:50%;' }
    	f.input :email_confirmation, :input_html => { :style => 'width:50%;' }
    	f.input :title, :input_html => { :style => 'width:50%;' }
    	f.input :relationship, :input_html => { :style => 'width:50%;' }
    	f.input :mentor_type, as: :select, collection: f.object.offering.mentor_types
    	f.input :waive_access_review_right, as: :boolean
		# f.input :academic_department, as: :tags, collection: AcademicDepartment.all.collect(&:name).sort
		f.input :academic_department, as: :select, collection: AcademicDepartment.all.collect(&:name).sort, :input_html => { multiple: true, class: "chosen-select", :style => 'width: 50%' }
    	f.input :approval_response, as: :select, collection: %w(revise approved)
  		f.input :approval_comments, as: :text, :input_html => { :class => 'autogrow', :rows => 5, :cols => 40  }
		f.input :approval_at, as: :datetime_picker, :input_html => { :style => 'width:50%;' }
    end
    f.actions
  end
 
  filter :firstname, as: :string
  filter :lastname, as: :string
  filter :email, as: :string
  filter :application_for_offering_id, as: :number

end 