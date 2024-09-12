# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_09_12_175251) do

  create_table "academic_departments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accountability_reports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "year"
    t.string "quarter_abbrevs"
    t.integer "activity_type_id"
    t.string "title"
    t.boolean "finalized"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "active_admin_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "author_id"
    t.string "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "department_id"
    t.string "title"
    t.integer "quarter_id"
    t.integer "ts_year"
    t.integer "ts_quarter"
    t.integer "course_branch"
    t.integer "course_no"
    t.string "dept_abbrev"
    t.string "section_id"
    t.date "start_date"
    t.date "end_date"
    t.string "type"
    t.integer "activity_course_id"
    t.integer "activity_type_id"
    t.string "preparer_uw_netid"
    t.string "notes"
    t.decimal "hours_per_week", precision: 10, scale: 2
    t.string "faculty_uw_netid"
    t.string "department_name"
    t.string "faculty_name"
    t.integer "system_key"
    t.decimal "number_of_hours", precision: 10, scale: 2
    t.integer "reporting_department_id"
    t.string "reporting_department_name"
  end

  create_table "activity_quarters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "quarter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "hours_per_week", precision: 10, scale: 2
    t.decimal "number_of_hours", precision: 10, scale: 2
    t.integer "activity_id"
  end

  create_table "activity_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "abbreviation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_interviews", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_answers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "offering_question_id"
    t.text "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "offering_question_option_id"
    t.index ["application_for_offering_id"], name: "index_application_answers_on_application_for_offering_id"
    t.index ["offering_question_id"], name: "index_application_answers_on_offering_question_id"
  end

  create_table "application_awards", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "requested_quarter_id"
    t.float "amount_requested"
    t.string "amount_requested_notes"
    t.float "amount_approved"
    t.string "amount_approved_notes"
    t.integer "amount_approved_user_id"
    t.float "amount_awarded"
    t.string "amount_awarded_notes"
    t.integer "amount_awarded_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "amount_disbersed"
    t.string "amount_disbersed_notes"
    t.integer "amount_disbersed_user_id"
    t.integer "disbersement_type_id"
    t.integer "disbersement_quarter_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.index ["application_for_offering_id"], name: "index_awards_on_app_id"
  end

  create_table "application_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_files", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.string "title"
    t.text "description"
    t.integer "offering_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "text_version"
    t.string "file"
    t.string "file_content_type"
    t.string "file_size"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.string "original_filename"
  end

  create_table "application_final_decision_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "application_status_type_id"
    t.boolean "yes_option"
    t.integer "offering_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_for_offerings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "selection_committee_access_ok"
    t.boolean "mentor_access_ok"
    t.string "local_or_permanent_address"
    t.string "project_title"
    t.text "project_description"
    t.string "hours_per_week"
    t.integer "how_did_you_hear_id"
    t.string "electronic_signature"
    t.date "electronic_signature_date"
    t.text "special_notes"
    t.integer "current_page_id"
    t.boolean "submitted"
    t.boolean "awarded"
    t.boolean "contingency"
    t.boolean "not_awarded"
    t.string "project_dates"
    t.text "other_scholarship_support"
    t.integer "feedback_person_id"
    t.text "review_committee_notes"
    t.text "interview_committee_notes"
    t.integer "application_review_decision_type_id"
    t.text "project_summary"
    t.integer "interview_feedback_person_id"
    t.integer "application_interview_decision_type_id"
    t.text "contingency_terms"
    t.date "contingency_checkin_date"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.text "how_did_you_hear"
    t.integer "current_application_status_id"
    t.datetime "awarded_at"
    t.datetime "approved_at"
    t.datetime "financial_aid_approved_at"
    t.datetime "disbursed_at"
    t.datetime "closed_at"
    t.text "award_letter_text"
    t.datetime "award_letter_sent_at"
    t.datetime "feedback_meeting_date"
    t.integer "feedback_meeting_person_id"
    t.text "feedback_meeting_comments"
    t.integer "application_type_id"
    t.integer "application_category_id"
    t.boolean "worked_with_mentor"
    t.boolean "attended_info_session"
    t.boolean "attended_advising_appointment"
    t.boolean "attended_feedback_appointment"
    t.string "other_category_title"
    t.integer "offering_session_id"
    t.integer "application_moderator_decision_type_id"
    t.text "moderator_comments"
    t.integer "offering_session_order"
    t.boolean "confirmed"
    t.text "theme_response"
    t.integer "nominated_mentor_id"
    t.text "nominated_mentor_explanation"
    t.text "theme_response2"
    t.text "review_comments"
    t.boolean "requests_printed_program"
    t.integer "location_section_id"
    t.integer "easel_number"
    t.string "mentor_department"
    t.boolean "lock_easel_number"
    t.integer "application_final_decision_type_id"
    t.text "final_committee_notes"
    t.boolean "declined"
    t.text "acceptance_response1"
    t.text "acceptance_response2"
    t.text "acceptance_response3"
    t.datetime "award_accepted_at"
    t.text "special_requests"
    t.text "task_completion_status_cache"
    t.integer "theme_response3"
    t.boolean "hide_proceeding_abstract"
    t.string "time_conflicts"
    t.index ["offering_id"], name: "index_applications_on_offering_id"
    t.index ["person_id"], name: "index_application_for_offerings_on_person_id"
  end

  create_table "application_group_members", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "person_id"
    t.boolean "verified"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "firstname"
    t.string "lastname"
    t.boolean "uw_student"
    t.datetime "validation_email_sent_at"
    t.integer "nominated_mentor_id"
    t.text "nominated_mentor_explanation"
    t.boolean "confirmed"
    t.text "theme_response"
    t.text "theme_response2"
    t.boolean "requests_printed_program"
    t.text "task_completion_status_cache"
    t.integer "theme_response3"
  end

  create_table "application_guests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "group_member_id"
    t.integer "application_mentor_id"
    t.string "firstname"
    t.string "lastname"
    t.text "address_block"
    t.boolean "uw_campus"
    t.datetime "invitation_mailed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "postcard_text"
  end

  create_table "application_interview_decision_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "application_status_type_id"
    t.boolean "yes_option"
    t.boolean "contingency_option"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "offering_id"
  end

  create_table "application_interviewers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "offering_interviewer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "comments"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.text "task_completion_status_cache"
  end

  create_table "application_mentor_answers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_mentor_id"
    t.integer "offering_mentor_question_id"
    t.text "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_mentor_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_mentors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "person_id"
    t.boolean "primary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "waive_access_review_right"
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.boolean "no_email"
    t.string "token"
    t.string "letter"
    t.string "letter_content_type"
    t.string "letter_size"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.datetime "invite_email_sent_at"
    t.string "email_confirmation"
    t.text "mentor_letter_text"
    t.datetime "mentor_letter_sent_at"
    t.integer "application_mentor_type_id"
    t.string "approval_response"
    t.text "approval_comments"
    t.datetime "approval_at"
    t.string "title"
    t.string "relationship"
    t.text "task_completion_status_cache"
    t.string "academic_department"
    t.boolean "confirm_primary"
    t.index ["application_for_offering_id"], name: "index_mentors_on_app_id"
    t.index ["person_id"], name: "index_mentors_on_person_id"
  end

  create_table "application_moderator_decision_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.boolean "yes_option"
    t.integer "offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_other_awards", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.boolean "secured"
    t.float "amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "application_for_offering_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "offering_other_award_type_id"
    t.integer "award_quarter_id"
  end

  create_table "application_pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "offering_page_id"
    t.boolean "complete"
    t.boolean "started"
    t.boolean "passed_validations"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.index ["application_for_offering_id"], name: "index_pages_on_app_id"
  end

  create_table "application_review_decision_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "application_status_type_id"
    t.boolean "yes_option"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "offering_id"
  end

  create_table "application_reviewer_scores", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_reviewer_id"
    t.integer "offering_review_criterion_id"
    t.integer "score"
    t.text "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["application_reviewer_id"], name: "index_application_reviewer_scores_on_application_reviewer_id"
    t.index ["offering_review_criterion_id"], name: "offering_review_criterion_index"
  end

  create_table "application_reviewers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "offering_reviewer_id"
    t.text "comments"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "committee_member_id"
    t.boolean "finalized"
    t.boolean "committee_score"
    t.text "task_completion_status_cache"
    t.index ["application_for_offering_id"], name: "index_reviewers_on_app_id"
    t.index ["committee_member_id"], name: "index_reviewers_on_committee_member_id"
    t.index ["offering_reviewer_id"], name: "index_reviewers_on_offering_reviewer_id"
  end

  create_table "application_status_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "application_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "application_status_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.index ["application_for_offering_id"], name: "index_statuses_on_app_id"
  end

  create_table "application_text_versions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_text_id"
    t.text "text"
    t.text "comments"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["application_text_id"], name: "index_text_versions_on_text_id"
  end

  create_table "application_texts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appointments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "staff_person_id"
    t.integer "student_id"
    t.datetime "check_in_time"
    t.integer "unit_id"
    t.text "notes"
    t.text "follow_up_notes"
    t.integer "previous_appointment_id"
    t.boolean "drop_in"
    t.string "type"
    t.text "front_desk_notes"
    t.string "source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "contact_type_id"
    t.index ["previous_appointment_id"], name: "index_appointments_on_previous_appointment_id"
    t.index ["staff_person_id"], name: "index_appointments_on_staff_person_id"
    t.index ["student_id"], name: "index_appointments_on_student_id"
  end

  create_table "award_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "scholar_title"
  end

  create_table "changes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "change_loggable_id"
    t.string "change_loggable_type"
    t.text "changes"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.string "action_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["change_loggable_id", "change_loggable_type"], name: "index_changes_on_changable"
  end

  create_table "class_standings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "abbreviation"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coalitions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coalitions_organizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "coalition_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "committee_meetings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "committee_id"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "title"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "location"
  end

  create_table "committee_member_meetings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "committee_member_id"
    t.integer "committee_meeting_id"
    t.boolean "attending"
    t.text "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committee_member_quarters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "committee_member_id"
    t.integer "committee_quarter_id"
    t.boolean "active"
    t.text "comment"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committee_member_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "committee_id"
    t.string "name"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "max_number_of_applicants_per_reviewer"
    t.text "extra_instructions"
    t.string "extra_instructions_link_text"
  end

  create_table "committee_members", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "committee_id"
    t.integer "person_id"
    t.integer "committee_member_type_id"
    t.string "expertise"
    t.string "website_url"
    t.integer "recommender_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "inactive"
    t.boolean "permanently_inactive"
    t.text "comment"
    t.text "notes"
    t.datetime "last_user_response_at"
    t.string "department"
    t.text "replacement_recommendation"
    t.string "status_cache"
    t.text "task_completion_status_cache"
  end

  create_table "committee_quarters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "committee_id"
    t.integer "quarter_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "comments_prompt_text"
    t.string "alternate_title"
  end

  create_table "committees", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "intro_text"
    t.text "inactive_text"
    t.text "complete_text"
    t.string "active_action_text"
    t.text "unit_signature"
    t.boolean "show_permanently_inactive_option"
    t.boolean "ask_for_replacement"
    t.date "response_reset_date"
    t.text "meetings_text"
    t.integer "interview_offering_id"
    t.string "meetings_alt_title"
  end

  create_table "contact_histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "person_id"
    t.text "type"
    t.text "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "application_status_id"
    t.integer "original_contact_history_id"
    t.string "contactable_type"
    t.integer "contactable_id"
    t.index ["application_status_id"], name: "application_status_id"
    t.index ["contactable_id"], name: "index_contact_histories_on_contactable_id"
    t.index ["contactable_type"], name: "index_contact_histories_on_contactable_type"
    t.index ["creator_id"], name: "index_contact_histories_on_creator_id"
    t.index ["original_contact_history_id"], name: "original_contact_history_index"
    t.index ["person_id"], name: "index_contact_histories_on_person_id"
  end

  create_table "contact_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "course_extra_enrollees", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "ts_year"
    t.integer "ts_quarter"
    t.integer "course_branch"
    t.integer "course_no"
    t.string "dept_abbrev"
    t.string "section_id"
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.index ["person_id"], name: "index_course_extra_enrollees_on_person_id"
    t.index ["ts_year", "ts_quarter", "course_branch", "course_no", "dept_abbrev", "section_id"], name: "course_id_index"
  end

  create_table "dashboard_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "icon"
    t.string "css_class"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "deleted_application_answers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "offering_question_id"
    t.text "answer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.datetime "deleted_at"
    t.integer "offering_question_option_id"
  end

  create_table "deleted_application_awards", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "requested_quarter_id"
    t.float "amount_requested"
    t.string "amount_requested_notes"
    t.float "amount_approved"
    t.string "amount_approved_notes"
    t.integer "amount_approved_user_id"
    t.float "amount_awarded"
    t.string "amount_awarded_notes"
    t.integer "amount_awarded_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "amount_disbersed"
    t.string "amount_disbersed_notes"
    t.integer "amount_disbersed_user_id"
    t.integer "disbersement_type_id"
    t.integer "disbersement_quarter_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.datetime "deleted_at"
  end

  create_table "deleted_application_files", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.string "title"
    t.text "description"
    t.integer "offering_question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "text_version"
    t.string "file"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.string "original_filename"
    t.datetime "deleted_at"
    t.string "file_content_type"
    t.string "file_size"
  end

  create_table "deleted_application_for_offerings", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "selection_committee_access_ok"
    t.boolean "mentor_access_ok"
    t.string "local_or_permanent_address"
    t.string "project_title"
    t.text "project_description"
    t.string "hours_per_week"
    t.integer "how_did_you_hear_id"
    t.string "electronic_signature"
    t.date "electronic_signature_date"
    t.text "special_notes"
    t.integer "current_page_id"
    t.boolean "submitted"
    t.boolean "awarded"
    t.boolean "contingency"
    t.boolean "not_awarded"
    t.string "project_dates"
    t.text "other_scholarship_support"
    t.integer "feedback_person_id"
    t.text "review_committee_notes"
    t.text "interview_committee_notes"
    t.integer "application_review_decision_type_id"
    t.text "project_summary"
    t.integer "interview_feedback_person_id"
    t.integer "application_interview_decision_type_id"
    t.text "contingency_terms"
    t.date "contingency_checkin_date"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.text "how_did_you_hear"
    t.datetime "deleted_at"
    t.integer "current_application_status_id"
    t.datetime "awarded_at"
    t.datetime "financial_aid_approved_at"
    t.datetime "closed_at"
    t.text "award_letter_text"
    t.datetime "approved_at"
    t.datetime "disbursed_at"
    t.datetime "award_letter_sent_at"
    t.datetime "feedback_meeting_date"
    t.integer "application_category_id"
    t.integer "application_type_id"
    t.text "feedback_meeting_comments"
    t.integer "feedback_meeting_person_id"
    t.boolean "attended_feedback_appointment"
    t.boolean "attended_advising_appointment"
    t.boolean "attended_info_session"
    t.boolean "worked_with_mentor"
    t.string "other_category_title"
    t.text "nominated_mentor_explanation"
    t.text "theme_response"
    t.integer "offering_session_order"
    t.boolean "confirmed"
    t.text "moderator_comments"
    t.integer "nominated_mentor_id"
    t.integer "offering_session_id"
    t.text "review_comments"
    t.text "theme_response2"
    t.integer "application_moderator_decision_type_id"
    t.boolean "lock_easel_number"
    t.integer "easel_number"
    t.string "mentor_department"
    t.integer "location_section_id"
    t.boolean "requests_printed_program"
    t.text "acceptance_response3"
    t.boolean "declined"
    t.integer "application_final_decision_type_id"
    t.text "final_committee_notes"
    t.datetime "award_accepted_at"
    t.text "acceptance_response1"
    t.text "acceptance_response2"
    t.text "special_requests"
    t.text "task_completion_status_cache"
    t.integer "theme_response3"
    t.boolean "hide_proceeding_abstract"
  end

  create_table "deleted_application_mentors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "person_id"
    t.boolean "primary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "waive_access_review_right"
    t.string "firstname"
    t.string "lastname"
    t.string "email"
    t.boolean "no_email"
    t.string "token"
    t.string "letter"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.datetime "invite_email_sent_at"
    t.string "email_confirmation"
    t.datetime "deleted_at"
    t.text "mentor_letter_text"
    t.string "letter_size"
    t.string "letter_content_type"
    t.datetime "mentor_letter_sent_at"
    t.integer "application_mentor_type_id"
    t.datetime "approval_at"
    t.string "approval_response"
    t.text "approval_comments"
    t.string "title"
    t.string "relationship"
    t.text "task_completion_status_cache"
    t.string "academic_department"
  end

  create_table "deleted_application_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_for_offering_id"
    t.integer "application_status_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.datetime "deleted_at"
  end

  create_table "deleted_organization_contacts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "organization_id"
    t.boolean "americorps"
    t.date "americorps_term_end_date"
    t.boolean "service_learning_contact"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.boolean "primary_service_learning_contact"
    t.boolean "current"
    t.boolean "pipeline_contact"
    t.text "note"
  end

  create_table "deleted_organization_quarters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "quarter_id"
    t.boolean "active"
    t.integer "staff_contact_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.boolean "allow_position_edits"
    t.boolean "allow_evals"
    t.datetime "deleted_at"
    t.integer "unit_id"
    t.integer "in_progress_positions_count"
    t.integer "pending_positions_count"
    t.integer "approved_positions_count"
    t.boolean "finished_evaluation"
  end

  create_table "deleted_organizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "default_location_id"
    t.integer "parent_organization_id"
    t.string "mailing_line_1"
    t.string "mailing_line_2"
    t.string "mailing_city"
    t.string "mailing_state"
    t.string "mailing_zip"
    t.string "website_url"
    t.string "main_phone"
    t.text "mission_statement"
    t.boolean "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "primary_service_learning_contact_id"
    t.datetime "deleted_at"
    t.boolean "inactive"
    t.boolean "archive"
    t.boolean "does_service_learning"
    t.integer "next_active_quarter_id"
    t.integer "school_type_id"
    t.boolean "target_school"
    t.string "type"
    t.boolean "does_pipeline"
    t.boolean "multiple_quarter"
    t.string "logo"
  end

  create_table "deleted_service_learning_courses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "alternate_title"
    t.string "quarter_id"
    t.string "syllabus"
    t.string "syllabus_url"
    t.text "overview"
    t.text "role_of_service_learning"
    t.text "assignments"
    t.datetime "presentation_time"
    t.integer "presentation_length"
    t.boolean "finalized"
    t.datetime "registration_open_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.integer "unit_id"
    t.text "students"
    t.boolean "no_filters"
    t.integer "pipeline_student_type_id"
    t.boolean "required"
    t.boolean "general_study"
  end

  create_table "deleted_service_learning_orientations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "start_time"
    t.integer "location_id"
    t.boolean "flexible"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.text "notes"
    t.datetime "deleted_at"
    t.boolean "different_orientation_contact"
    t.boolean "different_orientation_location"
    t.integer "organization_contact_id"
  end

  create_table "deleted_service_learning_placements", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "service_learning_position_id"
    t.integer "service_learning_course_id"
    t.datetime "waiver_date"
    t.string "waiver_signature"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.integer "confirmation_history_id"
    t.datetime "confirmed_at"
    t.integer "quarter_update_history_id"
    t.integer "unit_id"
    t.datetime "tutoring_submitted_at"
  end

  create_table "deleted_service_learning_position_times", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_position_id"
    t.time "start_time"
    t.time "end_time"
    t.boolean "flexible"
    t.boolean "monday"
    t.boolean "tuesday"
    t.boolean "wednesday"
    t.boolean "thursday"
    t.boolean "friday"
    t.boolean "saturday"
    t.boolean "sunday"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
  end

  create_table "deleted_service_learning_positions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "organization_quarter_id"
    t.integer "location_id"
    t.text "description"
    t.string "age_requirement"
    t.string "duration_requirement"
    t.text "alternate_transportation"
    t.integer "previous_service_learning_position_id"
    t.integer "supervisor_person_id"
    t.text "time_notes"
    t.integer "service_learning_orientation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.boolean "self_placement"
    t.boolean "approved"
    t.datetime "deleted_at"
    t.text "context_description"
    t.integer "ideal_number_of_slots"
    t.text "impact_description"
    t.string "time_commitment_requirement"
    t.text "paperwork_requirement"
    t.boolean "tb_test_required"
    t.boolean "in_progress"
    t.boolean "background_check_required"
    t.text "skills_requirement"
    t.boolean "times_are_flexible"
    t.text "other_duration_requirement"
    t.text "other_age_requirement"
    t.integer "bus_trip_time"
    t.integer "unit_id"
    t.boolean "use_slots"
    t.integer "filled_placements_count"
    t.integer "unallocated_placements_count"
    t.integer "total_placements_count"
    t.boolean "general_study"
    t.text "learning_goals"
    t.text "academic_topics"
    t.text "sources"
    t.boolean "public_service"
    t.integer "total_hours"
    t.integer "credit"
    t.integer "volunteer"
    t.decimal "compensation", precision: 8, scale: 2
    t.boolean "flu_vaccination_required"
    t.boolean "food_permit_required"
    t.boolean "other_health_required"
    t.string "other_health_requirement"
    t.boolean "legal_name_required"
    t.boolean "birthdate_required"
    t.boolean "ssn_required"
    t.boolean "fingerprint_required"
    t.boolean "other_background_check_required"
    t.string "other_background_check_requirement"
    t.boolean "non_intl_student_required"
    t.date "volunteer_since"
    t.boolean "paid"
    t.boolean "religious"
    t.boolean "group_ok"
    t.string "picture"
    t.integer "education_sector"
  end

  create_table "department_extras", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "dept_code"
    t.string "fixed_name"
    t.string "chair_name"
    t.string "chair_email"
    t.string "chair_title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "temp_num_students"
    t.index ["dept_code"], name: "dept_code", unique: true
  end

  create_table "disbersement_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "discipline_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_queues", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.text "email"
    t.integer "application_status_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "application_status_id"
    t.text "command_after_delivery"
    t.integer "original_contact_history_id"
    t.string "contactable_type"
    t.integer "contactable_id"
    t.text "error_details"
  end

  create_table "equipment", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "tag"
    t.string "title"
    t.integer "equipment_category_id"
    t.datetime "warranty_expiration_date"
    t.boolean "ready_for_checkout"
    t.string "local_picture"
    t.text "description"
    t.boolean "staff_only"
    t.text "special_instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "purchase_date"
    t.string "serial_number"
    t.text "included_accessories"
    t.text "included_software"
    t.float "replacement_fee"
    t.string "inventory_number"
    t.string "warranty_number"
    t.string "hardware_address"
  end

  create_table "equipment_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "max_checkout_days"
    t.text "staff_instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "picture"
    t.integer "max_items_per_checkout", default: 1
    t.integer "buffer_days_between_checkouts", default: 1
    t.text "checkout_instructions"
    t.text "checkin_instructions"
    t.boolean "requires_staff_intervention_before_next_checkout"
    t.boolean "requires_reimage_before_next_checkout"
    t.string "as_same_category"
  end

  create_table "equipment_reservation_equipments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "equipment_reservation_id"
    t.integer "equipment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "equipment_reservations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.datetime "policy_agreement_date"
    t.text "project_description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer "unit_id"
    t.integer "approver_id"
    t.datetime "approved_at"
    t.datetime "checked_out_at"
    t.string "checkout_id_verify"
    t.integer "checkout_user_id"
    t.datetime "checked_in_at"
    t.integer "checkin_user_id"
    t.boolean "checkin_ok"
    t.text "checkin_notes"
    t.boolean "submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "status"
    t.boolean "staff"
    t.boolean "program_hold"
  end

  create_table "evaluation_questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "evaluation_questionable_id"
    t.string "evaluation_questionable_type"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "question"
    t.string "display_as"
    t.integer "sequence"
    t.boolean "required"
    t.integer "unit_id"
    t.boolean "general_study"
  end

  create_table "evaluation_responses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "evaluation_id"
    t.integer "evaluation_question_id"
    t.text "response"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "notes"
    t.index ["evaluation_id"], name: "index_evaluation_responses_on_evaluation_id"
  end

  create_table "evaluations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "evaluatable_id"
    t.string "evaluatable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "completer_person_id"
    t.string "completer_name"
    t.text "completer_reason"
    t.datetime "submitted_at"
    t.index ["evaluatable_id", "evaluatable_type"], name: "index_evaluations_on_evaluatable"
  end

  create_table "event_invitees", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_time_id"
    t.string "invitable_type"
    t.integer "invitable_id"
    t.boolean "attending"
    t.text "rsvp_comments"
    t.integer "number_of_guests"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "sub_time_id"
    t.datetime "checkin_time"
    t.text "checkin_notes"
    t.integer "person_id"
    t.boolean "mobile_checkin"
    t.index ["event_time_id"], name: "index_event_invitees_on_event_time_id"
    t.index ["invitable_id", "invitable_type"], name: "index_event_invitees_on_invitable"
  end

  create_table "event_staff_position_shifts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_staff_position_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text "details"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_staff_positions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_id"
    t.string "title"
    t.integer "capacity"
    t.text "description"
    t.text "instructions"
    t.integer "training_session_event_id"
    t.text "restrictions"
    t.boolean "require_all_shifts"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_staffs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_staff_position_shift_id"
    t.integer "person_id"
    t.text "comments"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_times", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "event_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "location_id"
    t.integer "capacity"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.string "location_text"
    t.integer "parent_time_id"
    t.string "type"
    t.string "title"
    t.string "facilitator"
  end

  create_table "event_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "allow_multiple_times_per_attendee"
    t.integer "capacity"
    t.text "restrictions"
    t.integer "offering_id"
    t.integer "confirmation_email_template_id"
    t.boolean "allow_guests"
    t.integer "unit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.boolean "public"
    t.boolean "allow_multiple_positions_per_staff"
    t.integer "staff_signup_email_template_id"
    t.text "extra_fields_to_display"
    t.text "other_nametags"
    t.boolean "show_application_location_in_checkin"
    t.integer "event_type_id"
    t.integer "activity_type_id"
    t.integer "pull_accountability_hours_from_application"
    t.integer "reminder_email_template_id"
  end

  create_table "favorite_pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "url"
    t.string "title"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "first_generation_pell_eligibles", primary_key: "system_key", id: :integer, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.boolean "first_gen"
    t.boolean "pell_eligible"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "general_study_faculties", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "uw_netid"
    t.string "code"
    t.string "employee_id"
    t.string "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "help_texts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "type"
    t.string "key"
    t.string "object_type"
    t.string "attribute_name"
    t.text "caption"
    t.text "example"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "tech_note"
    t.string "title"
    t.boolean "plain_text"
  end

  create_table "interview_availabilities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_interview_timeblock_id"
    t.integer "application_for_offering_id"
    t.integer "offering_interviewer_id"
    t.time "time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.index ["application_for_offering_id"], name: "index_availabilities_on_app_id"
  end

  create_table "locations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "address_city"
    t.string "address_state"
    t.string "address_zip"
    t.text "driving_directions"
    t.text "bus_directions"
    t.text "notes"
    t.integer "site_supervisor_person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "organization_id"
    t.string "neighborhood"
  end

  create_table "login_histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "session_id"
    t.string "ip"
    t.index ["session_id"], name: "session_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "major_extras", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "major_branch"
    t.integer "major_pathway"
    t.integer "major_last_yr"
    t.integer "major_last_qtr"
    t.string "major_abbr"
    t.string "fixed_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "chair_name"
    t.string "chair_email"
    t.integer "temp_num_students"
    t.integer "discipline_category_id"
    t.index ["major_branch", "major_pathway", "major_last_yr", "major_last_qtr", "major_abbr"], name: "major_index"
  end

  create_table "notes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "contact_type_id"
    t.integer "notable_id"
    t.string "notable_type"
    t.string "creator_name"
    t.string "category"
    t.string "access_level"
    t.index ["notable_id", "notable_type"], name: "notable_index"
  end

  create_table "offering_admin_phase_task_completion_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "task_id"
    t.string "taskable_type"
    t.integer "taskable_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.text "result"
    t.boolean "complete"
    t.text "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["task_id"], name: "task_id_index"
    t.index ["taskable_type", "taskable_id"], name: "taskable_index"
  end

  create_table "offering_admin_phase_task_extra_fields", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_admin_phase_task_id"
    t.string "title"
    t.text "display_method"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_admin_phase_tasks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_admin_phase_id"
    t.string "title"
    t.boolean "complete"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "display_as"
    t.string "application_status_types"
    t.string "new_application_status_type"
    t.string "email_templates"
    t.boolean "show_history"
    t.integer "sequence"
    t.text "applicant_list_criteria"
    t.text "reviewer_list_criteria"
    t.text "detail_text"
    t.string "url", limit: 500
    t.text "notes"
    t.string "progress_column_title"
    t.text "progress_display_criteria"
    t.string "context"
    t.boolean "show_for_success"
    t.boolean "show_for_failure"
    t.boolean "show_for_in_progress"
    t.text "completion_criteria"
    t.boolean "show_for_context_object_tasks"
    t.text "context_object_completion_criteria"
    t.text "context_object_progress_display_criteria"
  end

  create_table "offering_admin_phases", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "display_as"
    t.integer "offering_id"
    t.integer "sequence"
    t.boolean "complete"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.text "notes"
    t.boolean "show_progress_completion", default: true
    t.boolean "show_each_status_separately"
    t.text "in_progress_application_status_types"
    t.text "success_application_status_types"
    t.text "failure_application_status_types"
  end

  create_table "offering_application_categories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_category_id"
    t.integer "offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "offering_application_type_id"
    t.boolean "other_option"
    t.integer "sequence"
  end

  create_table "offering_application_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "application_type_id"
    t.integer "offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "allow_other_category"
    t.integer "workshop_event_id"
  end

  create_table "offering_award_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "award_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_committee_member_restrictions", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "committee_member_type_id"
    t.integer "min_per_applicant"
    t.integer "max_applicants_per"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_committee_member_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "committee_member_type_id"
    t.integer "min_per_applicant"
    t.integer "max_applicants_per"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_dashboard_items", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "dashboard_item_id"
    t.text "criteria"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "sequence"
    t.boolean "show_group_members"
    t.integer "offering_application_type_id"
    t.string "status_lookup_method"
    t.integer "offering_status_id"
    t.boolean "disabled"
  end

  create_table "offering_interview_applicants", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_interview_id"
    t.integer "application_for_offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "offering_interview_interviewer_scores", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_interview_interviewer_id"
    t.integer "offering_review_criterion_id"
    t.integer "score"
    t.text "comments"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_interview_interviewers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_interview_id"
    t.integer "offering_interviewer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "comments"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.boolean "finalized"
    t.boolean "committee_score"
  end

  create_table "offering_interview_timeblocks", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.date "date"
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "offering_interviewer_conflict_of_interests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_interviewer_id"
    t.integer "application_for_offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "offering_interviewers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "special_notes"
    t.boolean "first_time"
    t.boolean "off_campus"
    t.boolean "past_scholar"
    t.datetime "interview_times_email_sent_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.datetime "invite_email_sent_at"
    t.integer "invite_email_contact_history_id"
    t.integer "interview_times_email_contact_history_id"
    t.integer "committee_member_id"
    t.text "task_completion_status_cache"
  end

  create_table "offering_interviews", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "start_time"
    t.string "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "offering_id"
    t.text "notes"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "offering_invitation_codes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.string "code"
    t.integer "application_for_offering_id"
    t.string "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "institution_id"
  end

  create_table "offering_location_sections", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "starting_easel_number"
    t.integer "ending_easel_number"
    t.string "color"
  end

  create_table "offering_mentor_questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.text "question"
    t.boolean "required"
    t.boolean "must_be_number"
    t.string "display_as"
    t.integer "size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_mentor_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "application_mentor_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "meets_minimum_qualification"
  end

  create_table "offering_other_award_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "award_type_id"
    t.boolean "ask_for_award_quarter"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "restrict_number_of_awards_to"
  end

  create_table "offering_page_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "offering_pages", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.string "title"
    t.string "description"
    t.integer "ordering"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "introduction"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.boolean "hide_in_admin_view"
    t.boolean "hide_in_reviewer_view"
  end

  create_table "offering_question_options", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_question_id"
    t.string "value"
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "associate_question_id"
    t.string "ordering"
  end

  create_table "offering_question_validations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_question_id"
    t.string "type"
    t.string "parameter"
    t.text "custom_error_text"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "offering_questions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_page_id"
    t.text "question"
    t.integer "ordering"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "required"
    t.string "validation_criteria"
    t.string "type"
    t.boolean "required_now"
    t.text "help_text"
    t.integer "character_limit"
    t.integer "word_limit"
    t.string "display_as"
    t.string "attribute_to_update"
    t.string "model_to_update"
    t.string "parameter1"
    t.integer "width"
    t.integer "height"
    t.text "caption"
    t.text "error_text"
    t.string "short_title"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.string "help_link_text"
    t.boolean "use_mce_editor"
    t.boolean "require_valid_phone_number"
    t.boolean "require_no_line_breaks"
    t.boolean "dynamic_answer"
    t.integer "option_column"
    t.integer "start_year"
    t.integer "end_year"
    t.boolean "hide_in_reviewer_view"
  end

  create_table "offering_restriction_exemptions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_restriction_id"
    t.integer "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "valid_until"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.text "note"
  end

  create_table "offering_restrictions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "type"
    t.text "extra_detail"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.text "parameter"
  end

  create_table "offering_review_criterions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.string "title"
    t.integer "max_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "description"
    t.integer "sequence"
  end

  create_table "offering_reviewers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "offering_sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.string "title"
    t.integer "moderator_id"
    t.text "moderator_comments"
    t.string "location"
    t.time "start_time"
    t.time "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "finalized"
    t.datetime "finalized_date"
    t.boolean "title_is_temporary"
    t.integer "offering_application_type_id"
    t.string "session_group"
    t.boolean "uses_location_sections"
    t.string "identifier"
    t.integer "presenters_count"
  end

  create_table "offering_status_emails", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_status_id"
    t.integer "email_template_id"
    t.boolean "auto_send"
    t.string "send_to"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.boolean "cc_to_feedback_person"
  end

  create_table "offering_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "offering_id"
    t.integer "application_status_type_id"
    t.text "message"
    t.string "public_title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "disallow_user_edits"
    t.boolean "disallow_all_edits"
    t.integer "sequence"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.boolean "allow_application_edits"
    t.boolean "allow_abstract_revisions"
    t.boolean "allow_abstract_confirmation"
    t.boolean "allow_confirmation"
  end

  create_table "offerings", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "unit_id"
    t.datetime "open_date"
    t.datetime "deadline"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "contact_name"
    t.string "contact_email"
    t.string "contact_phone"
    t.integer "number_of_awards"
    t.float "default_award_amount"
    t.integer "max_number_of_mentors"
    t.integer "quarter_offered_id"
    t.text "final_text"
    t.integer "min_number_of_awards"
    t.integer "max_number_of_awards"
    t.integer "min_number_of_mentors"
    t.integer "max_quarters_ahead_for_awards"
    t.string "notify_email"
    t.text "mentor_instructions"
    t.string "destroy_by"
    t.integer "interview_time_for_applicants"
    t.integer "interview_time_for_interviewers"
    t.integer "dean_approver_id"
    t.integer "financial_aid_approver_id"
    t.integer "disbersement_approver_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.integer "current_offering_admin_phase_id"
    t.integer "review_committee_id"
    t.integer "interview_committee_id"
    t.boolean "allow_early_mentor_submissions"
    t.integer "early_mentor_invite_email_template_id"
    t.integer "mentor_thank_you_email_template_id"
    t.integer "min_number_of_reviews_per_applicant"
    t.text "reviewer_instructions"
    t.text "interviewer_instructions"
    t.text "reviewer_help_text"
    t.integer "applicant_award_letter_template_id"
    t.integer "mentor_award_letter_template_id"
    t.boolean "uses_interviews"
    t.datetime "financial_aid_approval_request_sent_at"
    t.string "type"
    t.integer "year_offered"
    t.boolean "ask_applicant_to_waive_mentor_access_right"
    t.boolean "allow_hard_copy_letters_from_mentors"
    t.integer "group_member_validation_email_template_id"
    t.string "alternate_stylesheet"
    t.boolean "allow_students_only"
    t.string "mentor_mode"
    t.boolean "require_invitation_codes_from_non_students"
    t.text "revise_abstract_instructions"
    t.integer "moderator_committee_id"
    t.text "moderator_instructions"
    t.text "moderator_criteria"
    t.boolean "uses_non_committee_review"
    t.text "confirmation_instructions"
    t.text "confirmation_yes_text"
    t.text "guest_invitation_instructions"
    t.text "guest_postcard_layout"
    t.text "theme_response_instructions"
    t.text "nomination_instructions"
    t.string "theme_response_title"
    t.string "theme_response2_instructions"
    t.string "theme_response_type"
    t.string "theme_response2_type"
    t.integer "theme_response_word_limit"
    t.integer "theme_response2_word_limit"
    t.text "notes"
    t.boolean "disable_confirmation"
    t.integer "application_for_offerings_count"
    t.integer "first_eligible_award_quarter_id"
    t.boolean "uses_moderators"
    t.boolean "uses_mentors", default: true
    t.string "reviewer_past_application_access"
    t.boolean "uses_group_members"
    t.boolean "uses_awards", default: true
    t.boolean "uses_confirmation"
    t.boolean "require_all_mentor_letters_before_complete"
    t.boolean "review_committee_submits_committee_score"
    t.boolean "interview_committee_submits_committee_score"
    t.boolean "uses_scored_interviews"
    t.text "interviewer_help_text"
    t.string "alternate_mentor_title"
    t.boolean "ask_for_mentor_relationship"
    t.boolean "ask_for_mentor_title"
    t.string "award_basis"
    t.float "final_decision_weight_ratio"
    t.boolean "uses_award_acceptance"
    t.boolean "enable_award_acceptance"
    t.integer "accepted_offering_status_id"
    t.integer "declined_offering_status_id"
    t.text "acceptance_yes_text"
    t.text "acceptance_no_text"
    t.text "acceptance_instructions"
    t.string "acceptance_question1"
    t.string "acceptance_question2"
    t.string "acceptance_question3"
    t.integer "activity_type_id"
    t.string "count_method_for_accountability"
    t.integer "accountability_quarter_id"
    t.string "alternate_welcome_page_title"
    t.datetime "mentor_deadline"
    t.boolean "deny_mentor_access_after_mentor_deadline"
    t.text "special_requests_text"
    t.boolean "uses_proceedings"
    t.boolean "uses_lookup"
    t.text "proceedings_welcome_text"
    t.string "proceedings_pdf_letterhead"
    t.boolean "allow_to_review_mentee", default: false
    t.datetime "confirmation_deadline"
    t.boolean "disable_signature"
    t.boolean "virtual_proceeding"
    t.datetime "proceeding_public_display_at"
  end

  create_table "omsfa_student_info", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.string "alt_email"
    t.string "current_address"
    t.string "current_city"
    t.string "current_state"
    t.string "current_zip"
    t.string "current_phone"
    t.string "permanent_address"
    t.string "permanent_city"
    t.string "permanent_state"
    t.string "permanent_zip"
    t.string "permanent_phone"
    t.string "parent_firstname"
    t.string "parent_lastname"
    t.string "parent_email"
    t.string "parent2_firstname"
    t.string "parent2_lastname"
    t.string "parent2_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_authentication_associations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string "handle"
    t.string "assoc_type"
    t.binary "server_url"
    t.binary "secret"
  end

  create_table "open_id_authentication_nonces", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "timestamp", null: false
    t.string "server_url"
    t.string "salt", default: "", null: false
  end

  create_table "organization_contact_units", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_contact_id", null: false
    t.integer "unit_id", null: false
    t.boolean "primary_contact"
    t.index ["organization_contact_id"], name: "organization_contact_id"
    t.index ["unit_id"], name: "unit_id"
  end

  create_table "organization_contacts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "organization_id"
    t.boolean "americorps"
    t.date "americorps_term_end_date"
    t.boolean "service_learning_contact"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.boolean "primary_service_learning_contact"
    t.boolean "current", default: true
    t.boolean "pipeline_contact"
    t.text "note"
  end

  create_table "organization_migrations", id: false, options: "ENGINE=MyISAM DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "id"
    t.string "name"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "contact1_name"
    t.string "contact1_title"
    t.string "contact1_phone"
    t.string "contact1_extension"
    t.string "contact1_fax"
    t.string "contact1_email"
    t.string "contact2_name"
    t.string "contact2_phone"
    t.string "contact2_email"
    t.text "overview", limit: 16777215
    t.text "site_notes", limit: 16777215
    t.string "url"
  end

  create_table "organization_quarter_status_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "sequence"
    t.string "abbreviation"
    t.boolean "hide_by_default"
  end

  create_table "organization_quarter_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_quarter_id"
    t.integer "organization_quarter_status_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.index ["organization_quarter_id"], name: "index_quarter_status_on_org_quarter_id"
  end

  create_table "organization_quarters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "quarter_id"
    t.boolean "active"
    t.integer "staff_contact_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.boolean "allow_position_edits"
    t.boolean "allow_evals"
    t.integer "unit_id"
    t.integer "in_progress_positions_count"
    t.integer "pending_positions_count"
    t.integer "approved_positions_count"
    t.boolean "finished_evaluation"
    t.index ["organization_id"], name: "index_organization_quarters_on_organization_id"
  end

  create_table "organizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "default_location_id"
    t.integer "parent_organization_id"
    t.string "mailing_line_1"
    t.string "mailing_line_2"
    t.string "mailing_city"
    t.string "mailing_state"
    t.string "mailing_zip"
    t.string "website_url"
    t.string "main_phone"
    t.text "mission_statement"
    t.boolean "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "primary_service_learning_contact_id"
    t.boolean "inactive"
    t.integer "next_active_quarter_id"
    t.boolean "archive"
    t.boolean "does_service_learning"
    t.string "type"
    t.integer "school_type_id"
    t.boolean "target_school"
    t.boolean "does_pipeline"
    t.boolean "multiple_quarter"
    t.string "logo"
  end

  create_table "people", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "firstname"
    t.string "lastname"
    t.string "type"
    t.integer "system_key"
    t.integer "student_no"
    t.integer "est_grad_qtr"
    t.string "nickname"
    t.integer "department_id"
    t.string "email"
    t.string "phone"
    t.string "token"
    t.string "salutation"
    t.integer "extension"
    t.string "address1"
    t.string "address2"
    t.string "address3"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "organization"
    t.string "title"
    t.datetime "contact_info_updated_at"
    t.string "gender"
    t.string "other_department"
    t.string "box_no"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.datetime "service_learning_risk_date"
    t.string "service_learning_risk_signature"
    t.integer "service_learning_risk_placement_id"
    t.datetime "service_learning_risk_paper_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "fax"
    t.string "fullname"
    t.datetime "sdb_update_at"
    t.text "address_block"
    t.integer "institution_id"
    t.string "major_1"
    t.string "major_2"
    t.string "major_3"
    t.integer "class_standing_id"
    t.string "award_ids"
    t.datetime "pipeline_orientation"
    t.datetime "pipeline_background_check"
    t.datetime "equipment_reservation_restriction_until"
    t.datetime "equipment_reservation_non_student_override_until"
    t.string "institution_name"
    t.boolean "pipeline_inactive"
    t.string "reg_id"
    t.boolean "service_learning_risk_date_extention"
    t.datetime "service_learning_moa_date"
    t.index ["email"], name: "index_people_on_email"
    t.index ["student_no"], name: "index_people_on_student_no"
    t.index ["system_key"], name: "index_people_on_system_key"
  end

  create_table "pipeline_course_filters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_course_id"
    t.text "filters"
  end

  create_table "pipeline_positions_favorites", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "pipeline_position_id"
    t.integer "service_learning_course_id"
  end

  create_table "pipeline_positions_grade_levels", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
  end

  create_table "pipeline_positions_grade_levels_links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "pipeline_position_id"
    t.integer "pipeline_positions_grade_level_id"
  end

  create_table "pipeline_positions_language_spokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pipeline_positions_language_spokens_links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "pipeline_position_id"
    t.integer "pipeline_positions_language_spoken_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pipeline_positions_subjects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
  end

  create_table "pipeline_positions_subjects_links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "pipeline_position_id"
    t.integer "pipeline_positions_subject_id"
  end

  create_table "pipeline_positions_tutoring_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
  end

  create_table "pipeline_positions_tutoring_types_links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "pipeline_position_id"
    t.integer "pipeline_positions_tutoring_type_id"
  end

  create_table "pipeline_student_info", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.text "how_did_you_hear"
    t.boolean "fulfill_mit"
    t.string "pursue_els"
    t.string "teaching_career"
    t.boolean "apply_masters"
    t.boolean "current_els_minor"
  end

  create_table "pipeline_student_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.text "description"
  end

  create_table "pipeline_tutoring_logs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_placement_id"
    t.decimal "hours", precision: 10, scale: 2
    t.date "log_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "population_conditions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "population_id"
    t.string "attribute_name"
    t.string "eval_method"
    t.text "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "population_group_members", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "population_group_id"
    t.integer "population_groupable_id"
    t.string "population_groupable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "population_groups", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "creator_id"
    t.integer "updater_id"
    t.string "access_level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "populations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "populatable_type"
    t.integer "populatable_id"
    t.string "starting_set"
    t.string "condition_operator"
    t.string "access_level"
    t.integer "creator_id"
    t.integer "updater_id"
    t.string "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "object_ids", limit: 16777215
    t.datetime "objects_generated_at"
    t.integer "objects_count"
    t.text "output_fields"
    t.boolean "system"
    t.integer "conditions_counter"
    t.text "custom_query"
    t.string "result_variant"
    t.text "custom_result_variant"
    t.boolean "deleted"
    t.datetime "deleted_at"
  end

  create_table "potential_course_organization_match_for_quarters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "organization_quarter_id"
    t.integer "service_learning_course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "potential_course_organization_match_instructor_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_course_instructor_id"
    t.integer "organization_quarter_id"
    t.text "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proceedings_favorites", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "application_for_offering_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "session_id"
    t.index ["session_id"], name: "index_proceedings_favorites_on_session_id"
    t.index ["user_id"], name: "index_proceedings_favorites_on_user_id"
  end

  create_table "quarter_codes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "abbreviation"
    t.string "name"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "quarters", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "year"
    t.date "first_day"
    t.date "last_day"
    t.date "registration_begins"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "quarter_code_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "quotes", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key"
    t.string "quotable_type"
    t.integer "quotable_id"
    t.text "quote"
    t.string "author"
    t.string "author_title"
    t.string "picture"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "research_areas", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "research_opportunities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "department"
    t.string "title"
    t.text "description"
    t.text "requirements"
    t.integer "research_area1"
    t.integer "research_area2"
    t.integer "research_area3"
    t.integer "research_area4"
    t.date "end_date"
    t.boolean "active"
    t.boolean "removed"
    t.boolean "submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "submitted_at"
    t.integer "submitted_person_id"
    t.boolean "paid"
    t.boolean "work_study"
    t.string "location"
    t.text "learning_benefit"
    t.string "availability"
    t.boolean "social"
    t.string "social_if_yes"
  end

  create_table "rights", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "controller"
    t.string "action"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "rights_roles", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "right_id"
    t.integer "role_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.text "description"
  end

  create_table "school_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
  end

  create_table "service_learning_course_courses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_course_id"
    t.integer "ts_year"
    t.integer "ts_quarter"
    t.integer "course_branch"
    t.integer "course_no"
    t.string "dept_abbrev"
    t.string "section_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "service_learning_course_extra_enrollees", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_course_id"
    t.integer "person_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["person_id"], name: "index_enrollees_on_person_id"
  end

  create_table "service_learning_course_instructors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_course_id"
    t.integer "person_id"
    t.boolean "ta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.text "note"
    t.text "comment"
  end

  create_table "service_learning_course_status_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "service_learning_course_statuses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_course_id"
    t.integer "service_learning_course_status_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "service_learning_courses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "alternate_title"
    t.string "quarter_id"
    t.string "syllabus"
    t.string "syllabus_url"
    t.text "overview"
    t.text "role_of_service_learning"
    t.text "assignments"
    t.datetime "presentation_time"
    t.integer "presentation_length"
    t.boolean "finalized"
    t.datetime "registration_open_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "unit_id"
    t.text "students"
    t.boolean "no_filters"
    t.integer "pipeline_student_type_id"
    t.boolean "required", default: false
    t.boolean "general_study"
  end

  create_table "service_learning_orientations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "start_time"
    t.integer "location_id"
    t.boolean "flexible"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.text "notes"
    t.boolean "different_orientation_contact"
    t.integer "organization_contact_id"
    t.boolean "different_orientation_location"
  end

  create_table "service_learning_placements", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "service_learning_position_id"
    t.integer "service_learning_course_id"
    t.datetime "waiver_date"
    t.string "waiver_signature"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "confirmed_at"
    t.integer "confirmation_history_id"
    t.integer "quarter_update_history_id"
    t.integer "unit_id"
    t.datetime "tutoring_submitted_at"
    t.index ["person_id"], name: "index_service_learning_placements_on_person_id"
    t.index ["service_learning_course_id"], name: "index_placements_on_course_id"
    t.index ["service_learning_position_id"], name: "index_placements_on_position_id"
  end

  create_table "service_learning_position_shares", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "unit_id"
    t.integer "service_learning_position_id"
    t.boolean "allow_edit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_learning_position_times", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_position_id"
    t.time "start_time"
    t.time "end_time"
    t.boolean "flexible"
    t.boolean "monday"
    t.boolean "tuesday"
    t.boolean "wednesday"
    t.boolean "thursday"
    t.boolean "friday"
    t.boolean "saturday"
    t.boolean "sunday"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.index ["service_learning_position_id"], name: "index_times_on_position_id"
  end

  create_table "service_learning_position_times_bak", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_position_id"
    t.time "start_time"
    t.time "end_time"
    t.boolean "flexible"
    t.boolean "monday"
    t.boolean "tuesday"
    t.boolean "wednesday"
    t.boolean "thursday"
    t.boolean "friday"
    t.boolean "saturday"
    t.boolean "sunday"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "service_learning_positions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "organization_quarter_id"
    t.integer "location_id"
    t.text "description"
    t.string "age_requirement"
    t.string "duration_requirement"
    t.text "alternate_transportation"
    t.integer "previous_service_learning_position_id"
    t.integer "supervisor_person_id"
    t.text "time_notes"
    t.integer "service_learning_orientation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.boolean "self_placement"
    t.boolean "approved"
    t.text "context_description"
    t.text "impact_description"
    t.text "skills_requirement"
    t.integer "ideal_number_of_slots"
    t.boolean "background_check_required"
    t.boolean "tb_test_required"
    t.text "paperwork_requirement"
    t.string "time_commitment_requirement"
    t.boolean "in_progress"
    t.boolean "times_are_flexible"
    t.text "other_age_requirement"
    t.text "other_duration_requirement"
    t.integer "bus_trip_time"
    t.integer "unit_id"
    t.boolean "use_slots"
    t.integer "filled_placements_count"
    t.integer "total_placements_count"
    t.integer "unallocated_placements_count"
    t.boolean "general_study"
    t.text "learning_goals"
    t.text "academic_topics"
    t.text "sources"
    t.boolean "public_service"
    t.integer "total_hours"
    t.integer "credit"
    t.integer "volunteer"
    t.decimal "compensation", precision: 8, scale: 2
    t.boolean "flu_vaccination_required"
    t.boolean "food_permit_required"
    t.boolean "other_health_required"
    t.string "other_health_requirement"
    t.boolean "legal_name_required"
    t.boolean "birthdate_required"
    t.boolean "ssn_required"
    t.boolean "fingerprint_required"
    t.boolean "other_background_check_required"
    t.string "other_background_check_requirement"
    t.boolean "non_intl_student_required"
    t.date "volunteer_since"
    t.boolean "paid"
    t.boolean "religious"
    t.boolean "group_ok"
    t.string "picture"
    t.boolean "education_sector"
    t.index ["organization_quarter_id"], name: "index_service_learning_positions_on_organization_quarter_id"
  end

  create_table "service_learning_positions_sector_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_learning_positions_sector_types_links", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "service_learning_position_id"
    t.integer "service_learning_positions_sector_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_learning_positions_skill_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_position_id"
    t.integer "skill_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "service_learning_positions_social_issue_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "service_learning_position_id"
    t.integer "social_issue_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "service_learning_self_placements", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "person_id"
    t.integer "service_learning_placement_id"
    t.integer "service_learning_position_id"
    t.integer "service_learning_course_id"
    t.integer "quarter_id"
    t.string "organization_id"
    t.string "organization_mailing_line_1"
    t.string "organization_mailing_line_2"
    t.string "organization_mailing_city"
    t.string "organization_mailing_state"
    t.string "organization_mailing_zip"
    t.string "organization_website_url"
    t.string "organization_contact_person"
    t.string "organization_contact_phone"
    t.string "organization_contact_title"
    t.string "organization_contact_email"
    t.text "organization_mission_statement"
    t.text "hope_to_learn"
    t.boolean "new_organization"
    t.boolean "submitted"
    t.boolean "faculty_approved"
    t.text "faculty_feedback"
    t.boolean "admin_approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "faculty_person_id"
    t.string "faculty_firstname"
    t.string "faculty_lastname"
    t.string "faculty_email"
    t.string "faculty_dept"
    t.string "faculty_phone"
    t.boolean "general_study", default: false, null: false
    t.boolean "supervisor_approved"
    t.text "supervisor_feedback"
    t.datetime "general_study_risk_date"
    t.string "general_study_risk_signature"
    t.integer "register_person_id"
    t.datetime "registered_at"
    t.text "admin_feedback"
  end

  create_table "session_histories", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "session_id"
    t.string "request_uri"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "request_method"
    t.index ["session_id"], name: "session_id"
  end

  create_table "sessions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "session_id", default: "", null: false
    t.text "data", limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "skill_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "social_issue_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "parent_social_issue_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
  end

  create_table "text_templates", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "body"
    t.string "name"
    t.string "subject"
    t.string "from"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.string "target_recipient"
    t.string "type"
    t.string "margins"
    t.string "font"
    t.boolean "lock_name"
  end

  create_table "tokens", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "tokenable_id"
    t.string "tokenable_type"
    t.string "token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["token"], name: "index_tokens_on_token"
    t.index ["tokenable_id", "tokenable_type"], name: "index_tokens_on_tokenable"
  end

  create_table "units", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.string "logo_uri"
    t.text "description"
    t.string "home_url"
    t.string "engage_url"
    t.boolean "show_on_expo_welcome"
    t.string "logo"
    t.boolean "show_on_equipment_reservation"
    t.string "phone"
    t.string "email"
  end

  create_table "user_email_addresses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_unit_role_authorizations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_unit_role_id"
    t.string "authorizable_type"
    t.integer "authorizable_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_unit_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.integer "unit_id"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "login"
    t.string "email"
    t.string "crypted_password", limit: 40
    t.string "salt", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "remember_token"
    t.datetime "remember_token_expires_at"
    t.string "identity_url"
    t.string "type"
    t.integer "person_id"
    t.string "token"
    t.string "identity_type"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
    t.boolean "admin"
    t.integer "default_email_address_id"
    t.datetime "ferpa_reminder_date"
    t.string "picture"
    t.index ["identity_type"], name: "identity_type"
    t.index ["login"], name: "login"
    t.index ["person_id"], name: "index_users_on_person_id"
  end

  create_table "users_user_unit_roles", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "creator_id"
    t.integer "updater_id"
    t.integer "deleter_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
