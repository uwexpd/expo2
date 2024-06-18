ActiveAdmin.register ApplicationMentor, as: 'mentor' do  
  batch_action :destroy, false
  config.per_page = [30, 50, 100, 200]
  config.sort_order = 'created_at_desc'
  menu parent: 'Groups', label: "<i class='mi padding_right'>supervised_user_circle</i> Mentors".html_safe

  scope "All", :with_name, default: true

  permit_params :primary, :application_for_offering_id, :person_id, :waive_access_review_right, :firstname, :lastname, :email, :email_confirmation, :application_mentor_type_id, :approval_response, :approval_comments, :approval_at, :title, :relationship, :return_to, academic_department: []

  controller do
    def create
      super do |format|
        redirect_to params[:application_mentor][:return_to] and return if resource.valid? && params[:application_mentor][:return_to].present?
      end
    end

    def update
      super do |format|
        redirect_to params[:application_mentor][:return_to] and return if resource.valid? && params[:application_mentor][:return_to].present?
      end
    end

    def destroy
      super do |format|
        redirect_to params[:return_to] and return if resource.valid? && params[:return_to].present?
      end
    end
  end

  index do
    column ('Name') {|mentor| link_to mentor.fullname, admin_mentor_path(mentor)}
    # column 'Person Record' do |mentor|
    #   mentor.person_id.nil? ? mentor.fullname : link_to(mentor.fullname, admin_person_path(mentor))
    # end
    column ('Email') {|mentor| mentor.email }
    column ('Offering') {|mentor| link_to(mentor.offering.title, admin_offering_path(mentor.offering)) if mentor.offering}
    column ('Project Title') {|mentor| mentor.application_for_offering.project_title.blank? ? link_to("(no title)", admin_offering_application_path(mentor.offering.id, mentor.application_for_offering_id)) : link_to(highlight(mentor.application_for_offering.stripped_project_title, params.dig(:q, :application_for_offering_project_title_contains))) }
    # column ('Created At') {|mentor| "#{time_ago_in_words mentor.created_at} ago"}
    actions
  end

  show do
    attributes_table do
      row :id
      row ('Fullname') do |mentor| 
                span mentor.person_id.nil? ? mentor.fullname : link_to(mentor.fullname, admin_person_path(mentor.person_id))
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
      f.input :application_for_offering_id, input_html: { style: 'width:25%;' }
      f.input :person_id, input_html: { style: 'width:25%;' }
      f.input :firstname, input_html: { style: 'width:50%;' }
      f.input :lastname, input_html: { style: 'width:50%;' }
      f.input :email, input_html: { style: 'width:50%;' }
      f.input :email_confirmation, input_html: { style: 'width:50%;' }
      f.input :title, input_html: {  style: 'width:50%;' }
      f.input :relationship, input_html: { style: 'width:50%;' }
      f.input :application_mentor_type_id, as: :select, collection: (Offering.find(mentor.offering.id).mentor_types.collect{|mt| [mt.title , mt.application_mentor_type_id]})
      f.input :waive_access_review_right, as: :boolean
      # Add +include_hidden: false+ to select for empty string removal. Refer to: https://github.com/select2/select2/issues/4484
      f.input :academic_department, as: :select, collection: AcademicDepartment.all.collect(&:name).sort,  include_hidden: false, input_html: { multiple: 'multiple', class: "select2", :style => 'width: 50%'}
      f.input :approval_response, as: :select, collection: %w(revise approved)
      f.input :approval_comments, as: :text, :input_html => { :class => 'autogrow', :rows => 5, :cols => 40  }
      f.input :approval_at, as: :date_time_picker, input_html: { :style => 'width:50%;' }
      f.input :return_to, as: :hidden, input_html: { value: params[:return_to] } if params[:return_to].present?
    end
    f.actions
  end
 
  filter :firstname, as: :string
  filter :lastname, as: :string
  filter :email, as: :string
  filter :application_for_offering_offering_id, label: 'Offering', as: :select, collection: Offering.order('id DESC'), input_html: { class: "select2", multiple: 'multiple'}
  filter :application_for_offering_project_title, as: :string, label: 'Project Title'

end 
