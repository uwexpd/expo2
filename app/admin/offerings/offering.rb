ActiveAdmin.register Offering do
  batch_action :destroy, false
  menu parent: 'Modules', label: 'Online Apps', :priority => 25
  config.sort_order = '' # Use blank to override the default sort by id in activeadmin
  config.per_page = [30, 50, 100, 200]

  scope 'Current Offerings', :sorting_current, default: true
  scope 'Past Offerings', :sorting_past
  scope 'All', :sorting

  permit_params :name, :unit_id, :open_date, :deadline, :description, :contact_name, :notify_email, :quarter_offered_id, :year_offered, :destroy_by, :notes, :activity_type_id, :count_method_for_accountability, :accountability_quarter_id, :uses_awards, :uses_group_members, :uses_mentors, :uses_interviews, :uses_moderators, :uses_confirmation, :uses_award_acceptance, :uses_lookup, :uses_proceedings, :number_of_awards, :default_award_amount, :min_number_of_awards, :max_number_of_awards, :first_eligible_award_quarter_id, :max_quarters_ahead_for_awards, :award_basis, :final_decision_weight_ratio, :dean_approver_id, :financial_aid_approver_id, :disbersement_approver_id, :allow_students_only, :require_invitation_codes_from_non_students, :disable_signature, :ask_applicant_to_waive_mentor_access_right, :ask_for_mentor_relationship, :ask_for_mentor_title, :final_text, :alternate_welcome_page_title, :revise_abstract_instructions, :group_member_validation_email_template_id, :max_number_of_mentors, :min_number_of_mentors, :mentor_deadline, :deny_mentor_access_after_mentor_deadline, :allow_hard_copy_letters_from_mentors, :allow_early_mentor_submissions, :require_all_mentor_letters_before_complete, :mentor_mode, :alternate_mentor_title, :early_mentor_invite_email_template_id, :mentor_thank_you_email_template_id, :review_committee_id, :min_number_of_reviews_per_applicant, :uses_non_committee_review, :review_committee_submits_committee_score, :allow_to_review_mentee, :reviewer_instructions, :interview_committee_id, :interview_time_for_applicants, :interview_time_for_interviewers, :uses_scored_interviews, :interview_committee_submits_committee_score, :interviewer_help_text, :interviewer_instructions, :enable_award_acceptance, :accepted_offering_status_id, :declined_offering_status_id, :acceptance_yes_text, :acceptance_no_text, :acceptance_question1, :acceptance_question2, :acceptance_question3, :acceptance_instructions, :moderator_committee_id, :moderator_instructions, :moderator_criteria, :disable_confirmation, :confirmation_deadline, :confirmation_instructions, :confirmation_yes_text, :guest_invitation_instructions, :guest_postcard_layout, :nomination_instructions, :theme_response_title, :theme_response_instructions, :theme_response_type, :theme_response_word_limit, :theme_response2_instructions, :theme_response2_type, :theme_response2_word_limit, :special_requests_text, :proceedings_welcome_text,
    # for has_many
    mentor_types_attributes: [:id, :offering_id, :application_mentor_type_id, :meets_minimum_qualification, :_destroy], mentor_questions_attributes: [:id, :offering_id, :question, :required, :must_be_number, :display_as, :size, :_destroy], review_criterions_attributes: [:id, :offering_id, :title, :max_score, :description, :sequence, :_destroy]

  controller do
    before_action :check_user_unit, :except => [ :index, :new, :create ]

    protected

    def check_user_unit
      @offering = Offering.find(params[:offering_id] || params[:id])
      require_user_unit @offering.unit
    end

  end

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
      span 'view_list', class: 'material-icons md-32'
      span link_to "Manage student applications (#{offering.valid_status_applications.size})", admin_apply_manage_path(offering)
    end
  end

  sidebar "Offering Settings", only: [:edit] do
  end
  
  form do |f|
    f.semantic_errors *f.object.errors.keys
    quarter_select = Quarter.all.select{|q|q.year > 1994}.sort_by(&:year).map{|q| [q.title, q.id]}
    email_templates = EmailTemplate.all.sort.pluck(:name, :id)
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
              status_tag "Review", style: "margin-top:3rem;"
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
            f.input :disbersement_approver_id, label: 'Disbersement', as: :select, collection: admin_users, include_blank: true, input_html: { class: "select2 minimum_input", style: "width: 30%"}
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
            f.input :group_member_validation_email_template_id, label: 'Group Member Validation E-mail Template', as: :select, collection: email_templates, include_blank: 'None', input_html: { class: 'select2', style: 'width: 100%'}
            div "Choose the email template that should be sent to group members to validate their participation in a group.", class: 'caption'
          end
        end
      end
      tab 'Mentors' do
        f.inputs 'Mentor' do
        hr
          f.input :max_number_of_mentors, label: 'Maximun', input_html: { :style => "width:7%;" }
          div 'Students cannot have more mentors than this.', class: 'caption'
          f.input :min_number_of_mentors, label: 'Maximun', input_html: { :style => "width:7%;" }
            div 'Students cannot have less mentors than this. If students can only have a specific number of mentors (e.g., one mentor), set both the minimum and maximum to the same value.', class: 'caption'
          f.input :mentor_deadline, as: :datetime_picker, input_html: { :style => "width:50%;" }
            div 'Specify a time by which mentors should complete their task (as defined by the Mentor Mode, below). This is blank by default and has no binding effect unless the "Deny mentor access after mentor deadline" checkbox is marked below. Otherwise, this is just used to provide an informational deadline for mentors when they log in.', class: 'caption'
          f.input :deny_mentor_access_after_mentor_deadline, as: :boolean
            div 'If this box is checked, mentors cannot get in to the mentor interface after the deadline defined above. If you leave this box unchecked, mentors can still get in after the deadline.', class: 'caption'
          f.input :allow_hard_copy_letters_from_mentors, as: :boolean
            div 'By default, we expect mentors to upload their letters using our online form. If your application process demands that mentors be allowed to submit letters in a different form, check this box. Applicants will be presented with a check box that says: "If your mentor cannot access the Internet and will need to submit a hard copy letter, please check here."', class: 'caption'
          f.input :allow_early_mentor_submissions, as: :boolean
            div 'If this box is checked, applicants can choose to request a letter from their mentor before they have submitted their application. By default, mentors are not notified to submit a letter until after the application is submitted. If an applicant chooses to invite a mentor to submit early (even if the mentor does not submit until later), the applicant is not allowed to remove that mentor from his or her application.', class: 'caption'
          f.input :require_all_mentor_letters_before_complete, as: :boolean
            div 'If this box is unchecked, the system will consider an application complete as soon as just one mentor submits a letter or approves the application.', class: 'caption'
          f.input :mentor_mode, as: :select, collection: ["abstract_approve", "no_interaction"], include_blank: "default"
            div "<strong>default:</strong> Mentors are asked to submit a letter of support through the online system. <strong>abstract_approve:</strong> Mentors approve the student's abstract instead of submitting a letter. <strong>no_interaction:</strong> Mentors do not interact with the online system (i.e., mentors are involved in a separate process, or only included on the application for informational purposes).".html_safe, class: 'caption'
          f.input :alternate_mentor_title, input_html: {style: 'width:50%'}
            div 'If you call your mentors something else (e.g., "Letter Writers") enter the singular form of the alternate title here (e.g., "Letter Writer").', class: 'caption'
        end

        f.inputs 'E-mail Templates' do
        hr
          f.input :early_mentor_invite_email_template_id, label: 'Early Invite', as: :select, collection:email_templates, include_blank: 'None', input_html: { class: 'select2', style: 'width: 70%'}
              div "Sent to a mentor before an applicant has submitted his or her application.", class: 'caption'
          f.input :mentor_thank_you_email_template_id, label: 'Thank you', as: :select, collection: email_templates, include_blank: 'None', input_html: { class: 'select2', style: 'width: 70%'}
              div "Sent to every mentor after he or she submits his or her letter.", class: 'caption'
        end

        f.inputs 'Mentor Instructions' do
        hr
          f.input :mentor_instructions, input_html: { class: "tinymce", rows: 15 }
          codes = %w(waived_right_note released_access_note firstname lastname his_her he_she)
          div "Valid placeholder codes: ", class: 'label' do
            codes.each do |code|
              span code, class: 'placeholder_text'
            end
          end
        end

        f.inputs 'Mentor Types' do
        hr
          f.has_many :mentor_types, allow_destroy: true do |mentor_type|
              mentor_type.input :application_mentor_type_id, as: :select, collection: ApplicationMentorType.all, :prompt => "Choose a mentor type"
              mentor_type.input :meets_minimum_qualification, as: :boolean
          end
        end

        f.inputs 'Mentor Questions' do
        hr
          f.has_many :mentor_questions, allow_destroy: true do |mentor_question|
              mentor_question.input :question, :input_html => { class: "tinymce", rows: 5, style: 'width: 70%' }
              mentor_question.input :required, as: :boolean
              mentor_question.input :must_be_number, as: :boolean
              mentor_question.input :display_as, as: :select, collection: ['short_response', 'long_response'], include_blank: false
              mentor_question.input :size, label: 'field input size', input_html: { style: 'width: 30%'}
          end
        end
      end
      tab 'Reviews' do
        f.inputs 'Reviews' do
          hr
          f.input :review_committee_id, as: :select, collection: Committee.all, include_blank: 'None', input_html: { class: 'select2', style: 'width: 70%'}
          f.input :min_number_of_reviews_per_applicant, label: 'Reviews required', input_html: { :style => "width:7%;" }
            div 'This defines the minimum number of reviews that every application must receive in order to be considered a valid review.', class: 'caption'
          div 'Options', class: 'label'
          f.input :uses_non_committee_review, as: :boolean
          f.input :review_committee_submits_committee_score, as: :boolean
            div 'Typically, all reviewer scores for an application are averaged together when making decisions. If your process requires that a review committee submit a separate committee score that will be used during the decision process, check this box. If checked, the review committee will also be asked for a decision recommendation.', class: 'caption'
          f.input :allow_to_review_mentee, as: :boolean
            div "Typically, all reviewers cannot review their mentees' applications. If checked, reviewers are able to do so.", class: 'caption'
          f.input :reviewer_help_text, label: 'Welcome text', :input_html => { class: "tinymce", rows: 5}
            div 'This bit of text is displayed in the "Welcome" box on the sidebar of the reviewer interface.', class: 'caption'
        end
        f.inputs 'Reviewer Instructions' do
          hr
          f.input :reviewer_instructions, label: 'Text that is available in a popup window that includes extra details about the process for reviewers.', :input_html => { :class => "tinymce", :rows => 20 }
        end
        f.inputs 'Review Criteria' do
          hr
          f.has_many :review_criterions, allow_destroy: true do |criterion|
              criterion.input :title, input_html: { style: 'width: 35%'}
              criterion.input :max_score, input_html: { style: 'width: 35%'}
              criterion.input :description, :input_html => { class: "tinymce", rows: 5}
              criterion.input :sequence, input_html: { style: 'width: 35%'}
          end
        end
      end
      tab 'Interviews' do
        f.inputs 'Interviews' do
          hr
          f.input :interview_committee_id, as: :select, collection: Committee.all, include_blank: 'None', input_html: { class: 'select2', style: 'width: 70%'}
          div 'Interview time', class: 'label'
          f.input :interview_time_for_applicants, label: 'For applicants:', as: :select, collection: 30.times.collect{|i| i*5+5}
          f.input :interview_time_for_interviewers, label: 'For interviewers:', as: :select, collection: 30.times.collect{|i| i*5+5}
          div 'Options', class: 'label'
          f.input :uses_scored_interviews, as: :boolean
            div 'By default, interviewers make a Yes/No decision as a committee about each applicant that they interview. If your interviewers are expected to provide a score, then check this box. Interviewers will score on the same review criteria as reviewers.', class: 'caption'
          f.input :interview_committee_submits_committee_score, as: :boolean
            div 'If the interview committee will submit a separate consensus score, check this box. If checked, the interview committee will also be asked for a decision recommendation.', class: 'caption'
          f.input :interviewer_help_text, label: 'Welcome text', :input_html => { class: "tinymce", rows: 5}
            div 'This bit of text is displayed in the "Welcome" box on the sidebar of the interview interface.', class: 'caption'
        end
        f.inputs 'Interviewer Instructions' do
          hr
          f.input :interviewer_instructions, label: "This text is displayed to an interviewer when he or she is looking at an applicant's information.", :input_html => { :class => "tinymce", :rows => 20 }
          end
      end
      tab 'Award Acceptance' do
        f.inputs 'Award Acceptance Process' do
          hr
          div 'The award acceptance process is used to allow students to accept or decline an award before they receive it. Only students who have been awarded by the awarding committee will be allowed to go through the award acceptance process.', class: 'instruction'
          f.input :enable_award_acceptance, as: :boolean
            div 'This allows applicants who have been awarded (based on award_basis) to accept or decline their awards.', class: 'caption'
          f.input :accepted_offering_status_id, label: 'If applicant accepts:', as: :select, collection: offering.statuses.sort.map{|s|[s.private_title, s.id]} , include_blank: 'None', input_html: { class: 'select2', style: 'width: 30%'}
            div "The applicant's status will be set to this as soon as he/she accepts his/her award.", class: 'caption'
          f.input :declined_offering_status_id, label: 'If applicant declines:', as: :select, collection: offering.statuses.sort.map{|s|[s.private_title, s.id]} , include_blank: 'None', input_html: { class: 'select2', style: 'width: 30%'}
            div "The applicant's status will be set to this as soon as he/she declines his/her award. Additionally, students who decline will no longer show as being awarded the scholarship.", class: 'caption'
          div 'Option text', class: 'label'
          f.input :acceptance_yes_text, label: "Accept option text:", as: :string
          f.input :acceptance_no_text, label: "Decline option text:", as: :string
            div 'These two text blocks are displayed right next to the bullets for accepting or declining on the award acceptance screen. HTML tags are allowed here. An example might be "<strong>Yes!</strong>, I accept this award."'.html_safe, class: 'caption'

          div 'Extra questions', class: 'label'
          f.input :acceptance_question1, label: "Question 1: ", as: :string
          f.input :acceptance_question2, label: "Question 2: ", as: :string
          f.input :acceptance_question3, label: "Question 3: ", as: :string
            div "Applicants will always be asked to accept or decline the award, but if you'd like to ask additional questions during the acceptance process, enter them here. Any question left blank will not appear on the screen when the applicant is looking at it.", class: 'caption'
        end
        f.inputs 'Acceptance Instructions' do
          hr
          f.input :acceptance_instructions, label: "This text is shown at the top of the award acceptance screen. U se <code>%award_quarter_list%</code> where you want to put in the list of award quarters.".html_safe, :input_html => { :class => "tinymce", :rows => 20 }
        end
      end
      tab 'Moderators' do
        f.inputs 'Moderator' do
          hr
          f.input :moderator_committee_id, as: :select, collection: Committee.all, include_blank: 'None', input_html: { class: 'select2', style: 'width: 70%'}
          f.input :moderator_instructions, :input_html => { :class => "tinymce", :rows => 15 }
          f.input :moderator_criteria, :input_html => { :class => "tinymce", :rows => 15 }
        end
      end
      tab 'Confirmation' do
        f.inputs 'Confirmation Process' do
          hr
          f.input :disable_confirmation, as: :boolean
            div 'This prevents applicants from accessing the confirmation process.', class: 'caption'
          f.input :confirmation_deadline, as: :datetime_picker, :input_html => { :style => "width:50%;" }
            div 'Students can confirm their participations anytime for first time confirmation. However, they cannot change their confirmations by confirmation deadline', class: 'caption'
          f.input :confirmation_instructions, :input_html => { :class => "tinymce", :rows => 15 }
          f.input :confirmation_yes_text, :input_html => { :class => "tinymce", :rows => 15 }
          f.input :guest_invitation_instructions, :input_html => { :class => "tinymce", :rows => 10 }
          f.input :guest_postcard_layout, :input_html => { :class => "tinymce", :rows => 7 }
            div 'Note that leave blank here will remove guest invitation section from the confirmation process.', class: 'caption'
          f.input :nomination_instructions, :input_html => { :class => "tinymce", :rows => 10 }
          f.input :theme_response_title, as: :string
            div 'Leave blank here will remove theme section from the confirmation process.', class: 'caption'
          f.input :theme_response_instructions, :input_html => { :class => "tinymce", :rows => 7 }
          columns do
            column min_width: "20%", max_width: "20%", style: "margin-right: 0" do
              f.input :theme_response_type, as: :select, collection: ["textfield", "textarea"]
            end
            column do
              f.input :theme_response_word_limit, :input_html => { stlye: 'width: 10%' }
            end
          end
          f.input :theme_response2_instructions, :input_html => { :class => "tinymce", :rows => 7 }
          columns do
            column min_width: "20%", max_width: "20%", style: "margin-right: 0" do
              f.input :theme_response2_type, as: :select, collection: ["textfield", "textarea"]
            end
            column do
              f.input :theme_response2_word_limit, :input_html => { stlye: 'width: 10%' }
            end
          end
          f.input :special_requests_text, :input_html => { :class => "tinymce", :rows => 5 }
        end
      end
      tab 'Proceedings' do
        f.inputs 'Online Proceedings' do
          hr
          f.input :proceedings_welcome_text, :input_html => { :class => "tinymce", :rows => 30 }
        end
      end
    end
    f.actions
  end
  
  filter :name, as: :string
  filter :open_date, as: :date_range
  filter :deadline, as: :date_range
  filter :unit_id, as: :select, collection: Unit.all.pluck(:abbreviation, :id), if: proc {@current_user.has_role?("user_manager")}

end