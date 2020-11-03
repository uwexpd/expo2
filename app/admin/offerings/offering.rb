ActiveAdmin.register Offering do
  batch_action :destroy, false    
  config.sort_order = '' # Use blank to override the default sort by id in activeadmin
  menu parent: 'Modules', label: 'Online Apps', :priority => 25
  
  scope 'All', :sorting, default: true
  scope 'Current Offerings', :current
  scope 'Past Offerings', :past

  permit_params :name, :unit_id, :open_date, :deadline, :description, :contact_name, :notify_email, :quarter_offered_id, :year_offered, :destroy_by, :notes, :activity_type_id, :count_method_for_accountability, :accountability_quarter_id, :uses_awards, :uses_group_members, :uses_mentors, :uses_interviews, :uses_moderators, :uses_confirmation, :uses_award_acceptance, :uses_lookup, :uses_proceedings, :number_of_awards, :default_award_amount, :min_number_of_awards, :max_number_of_awards, :first_eligible_award_quarter_id, :max_quarters_ahead_for_awards, :award_basis, :final_decision_weight_ratio, :dean_approver_id, :financial_aid_approver_id, :disbersement_approver_id, :allow_students_only, :require_invitation_codes_from_non_students, :disable_signature, :ask_applicant_to_waive_mentor_access_right, :ask_for_mentor_relationship, :ask_for_mentor_title, :final_text, :alternate_welcome_page_title, :revise_abstract_instructions, :group_member_validation_email_template_id

  index do
    column ('Name') {|offering| link_to(offering.name, admin_offering_path(offering)) }
    column ('Unit') {|offering| link_to(offering.unit.abbreviation, admin_unit_path(offering.unit)) if offering.unit }
    column ('Quarter') {|offering|  offering.quarter_offered ? offering.quarter_offered.title : offering.year_offered }
    column ('Current Phase') {|offering| offering.current_offering_admin_phase.name rescue nil }
    column ('Applications') {|offering| link_to "#{offering.application_for_offerings.valid_status.size.to_s} Apps", admin_apply_manage_path(offering) unless offering.application_for_offerings_count.nil? }
    actions
  end
  
  show do
      render 'show', { offering: offering}
  end
  
  sidebar "Applications", only: :show do
    div class: "information" do
      i 'view_list', class: 'material-icons md-32'
      span link_to "Manage student applications (#{offering.valid_status_applications.size})", admin_apply_manage_path(offering)
    end
  end

  sidebar "Offering Settings", only: [:edit] do
    
  end
  
  sidebar "More Settings", only: [:show, :edit] do
     
  end

  
  form do |f|
    f.semantic_errors *f.object.errors.keys
    quarter_select = Quarter.all.select{|q|q.year > 1994}.sort_by(&:year).map{|q| [q.title, q.id]}
    tabs do
      tab 'Main Details' do 
        f.inputs 'Main Details' do
          hr
          f.input :name, as: :string
          div 'The official name of this offering. This will automatically be combined with the quarter or year
      			of the offering. Example: Entering "Mary Gates Leadership Scholarship" will be displayed as "Mary Gates Leadership
      			Scholarship Autumn 2008" when displayed in lists.', class: 'caption'
          f.input :unit,  as: :select, required: true
          f.input :open_date, as: :datetime_picker, :input_html => { :style => "width:50%;" }
          f.input :deadline, as: :datetime_picker, :input_html => { :style => "width:50%;" }
          f.input :description, :input_html => { :class => "tinymce", :rows => 7 }
          div 'Displayed in public listings of available offerings when a student logs in.', class: 'caption'
          f.input :contact_name
          div 'This contact information is displayed in error messages and other messages.', class: 'caption'
          f.input :contact_email
          f.input :contact_phone
          f.input :notify_email, label: 'Notifications email'
          div 'Where should notifications of submitted applications go? Separate multiple email addresses with commas.', class: 'caption'
          f.input :quarter_offered_id, as: :select, collection: quarter_select, include_blank: true
          f.input :year_offered, as: :select, collection: 1995..Time.now.year+5, include_blank: true
          div 'Specify a year instead of a quarter if this offering spans more time or only happens annually.', class: 'caption'
          f.input :destroy_by, :input_html => { :style => "width:30%;" }
          div 'This date is added to the top of pages when printed or converted to PDF.', class: 'caption'
          f.input :notes, :input_html => {  :class => "tinymce", :rows => 4, :style => "width:100%;" }
          div 'Use this space to track internal notes about this offering.', class: 'caption'
        end
        f.inputs 'Accountability Settings' do
          hr
          div 'If students from this application process should be included in accountability data, change these settings to
          	control the way that applications will be counted.', class: 'intro'
          f.input :activity_type_id, as: :select, collection: ActivityType.all, :include_blank => "Do not include in accountability reports"
          div 'Choose the type of activity that this work is eligible to be counted for.', class: 'caption'
          f.input :count_method_for_accountability, as: :select, collection: %w(awardees complete presenters), :include_blank => true
          div "Determines which applicants should be counted. <strong>Awardees</strong> = only applicants who
               have been awarded. <strong>Complete</strong> = applicants who have move past the 'complete' status.
               <strong>Presenters</strong> = all applicants (including group members) who are included in a presentation session (only used for offering processes that include sessions).".html_safe, class: 'caption'
          f.input :accountability_quarter_id, as: :select, collection: quarter_select, include_blank: 'Use offering quarter'
          div "If this activity should be counted for a different quarter for accountability purposes, set that quarter here. The default option is to use the offering quarter. <strong>Note:</strong> you must set this value if this offering does not have an offering quarter; otherwise, it will not be counted at all.".html_safe, class: 'caption'
        end
      end
      tab 'Features' do
        f.inputs do
          render 'features', { offering: offering}
        end
      end
      tab 'Awards' do
        f.inputs 'Award Parameteres' do
          hr
          f.input :number_of_awards, label: 'Default number', :input_html => { :style => "width:7%;" }
          div 'Every student starts with this number of awards as default. Use the minimum and maximum below to control whether or not a student can add or remove additional quarters of funding.', class: 'caption'
          f.input :default_award_amount, label: 'Default amount', :input_html => { :style => "width:15%;" }
          div 'The default amount of funding for each quarter. Staff can decrease or increase individual awards on a case-by-case basis later in the process.', class: 'caption'
          f.input :min_number_of_awards, label: 'Munimun number', :input_html => { :style => "width:7%;" }
          f.input :max_number_of_awards, label: 'Maximun number', :input_html => { :style => "width:7%;" }
          f.input :first_eligible_award_quarter_id, as: :select, collection: quarter_select, include_blank: true
          div 'What is the first eligible quarter that can be selected as an award quarter?', class: 'caption'
          f.input :max_quarters_ahead_for_awards, label: 'Max. quarters ahead ', :input_html => { :style => "width:7%;" }
          div "How many quarters ahead can the student select as award quarters? Set this to <strong>0</strong> if students can only select the next upcoming quarter. Set this to <strong>1</strong> to let students have a buffer quarter, and so on. Note that students are always allowed to skip summer quarter.".html_safe, class: 'caption'
          f.input :award_basis, as: :select, collection: ["review", "interview", "final"]
          div "Sets the basis that the system should use for determining whether or not an applicant has been 'awarded.' Unlike some systems, there is not a simple 'awarded' flag that can be set on an applicant record. Instead, the system calculates the applicant's award status on-the-fly based on this value. For example, if this is set to 'interview,' then EXPO will look at the interview committee's decision to determine if the applicant was awarded.", class: 'caption'

          columns do
            column max_width: "50px", min_width: "50px" do
              status_tag "Review", style: "margin-top:3rem"
            end
            column do
              f.input :final_decision_weight_ratio
            end
            column do
              status_tag "Interview", style: "margin-top:3rem; margin-left: -1rem"
            end
          end
          div "Sets the weight ratio to use when determining combined scores for the 'final decision' process. This is only used when the review committee or interview committee is not the final decision-maker in the process. This value should be a decimal ratio value weighting the review committee score to the interview committee score. For example, a value here of '0.30' will make weight the computed scores 30% to the review committee score and 70% to the interview committee score. Defaults to 0.50 (50/50 even split).", class: 'caption'
          end

        f.inputs 'Award Approval Workflow Users' do
            hr
            admin_users = User.admin.pluck(:login, :id)
            f.input :dean_approver_id, label: 'Dean', as: :select, collection: admin_users, include_blank: true, input_html: { class: "select2 minimum_input", style: "width: 30%"}
            f.input :financial_aid_approver_id, label: 'Financial aid', as: :select, collection: admin_users, include_blank: true, input_html: { class: "select2 minimum_input", style: "width: 30%"}
            f.input :disbersement_approver_id, label: 'Disbersement', as: :select, collection: admin_users, include_blank: true, input_html: { class: "select2 minimum_input", style: "width: 30%"}:q
        end
      end

      tab 'Applicants' do
        f.inputs 'Applicant Settings' do
        hr
          f.input :allow_students_only, label: 'Only allow Students to apply', as: :boolean
            div "Uncheck this box to allow non-students to create applications for this offering. This allows anyone in the world to create an account in EXPO and start an application.", class: 'caption'
          f.input :require_invitation_codes_from_non_students, as: :boolean
            div "If you allow non-students to apply (above), mark this box to require that they use a special Invitation Code in order to create an application. This allows you to hand out invitation codes to individuals at other institutions, or elsewhere, just like class add codes.", class: 'caption'
          f.input :disable_signature, label: 'Disable digital signature', as: :boolean
            div "Check this box to hide the electronic signature input box on the 'Review and Submit' page. Students won't need to enter their electronic signatures.", class: 'caption'
          f.input :ask_applicant_to_waive_mentor_access_right, as: :boolean
            div "With this box checked, students are asked to waive their right to view their mentor's letter of support &mdash; a right which is guaranteed undeßr FERPA. They will see: 'The Family Education Rights and Privacy Act of 1974 and its amendments guarantee you access to educational records concerning yourself. However, those writing recommendations and those assessing them may attach more significance to them if it is known that they will retain confidentiality. You are permitted by those laws to voluntarily waive that right of access.'".html_safe, class: 'caption'
          f.input :ask_for_mentor_relationship, as: :boolean
            div "If this box is checked, students are asked 'How do you know this person?' when submitting their mentors' contact information.", class: 'caption'
          f.input :ask_for_mentor_title, as: :boolean
            div "If this box is checked, students are asked for their mentors' titles. Usually students are only asked for the mentor's name and email address.", class: 'caption'
          f.input :final_text, :input_html => { :class => "tinymce", :rows => 7 }
            div "This text is displayed to the applicant on the 'Review and Submit' page, directly above the student's digital signature. Example: 'I understand that if awarded this scholarship...'", class: 'caption'
          f.input :alternate_welcome_page_title, label: 'Dashboard title', :input_html => { :style => "width:50%;" }
            div "By default, the applicant welcome page (or 'dashboard') is labeled simply as 'Welcome.' To override this, specify a new dashboard title here.", class: 'caption'
          f.input :revise_abstract_instructions, :input_html => { :class => "tinymce", :rows => 7 }
          div "These instructions are shown to applicants on the 'Revise Abstract' page.", class: 'caption'
          if offering.uses_group_members?
            f.input :group_member_validation_email_template_id, label: 'Group Member Validation E-mail Template', as: :select, collection: EmailTemplate.all.sort.pluck(:name, :id), include_blank: 'None', input_html: { class: 'select2'}
            div "Choose the email template that should be sent to group members to validate their participation in a group.", class: 'caption'
          end

        end

      end

    end
    f.actions
  end
  
  filter :name, as: :string
  filter :open_date, as: :date_range
  filter :deadline, as: :date_range
  filter :unit_id, as: :select, collection: Unit.all.pluck(:abbreviation, :id)

end