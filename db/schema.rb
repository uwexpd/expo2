# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160520190543) do

  create_table "academic_departments", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accountability_reports", force: :cascade do |t|
    t.integer  "year",             limit: 4
    t.string   "quarter_abbrevs",  limit: 255
    t.integer  "activity_type_id", limit: 4
    t.string   "title",            limit: 255
    t.boolean  "finalized"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace",     limit: 255
    t.text     "body",          limit: 65535
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "activities", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                limit: 4
    t.integer  "updater_id",                limit: 4
    t.integer  "deleter_id",                limit: 4
    t.integer  "department_id",             limit: 4
    t.string   "title",                     limit: 255
    t.integer  "quarter_id",                limit: 4
    t.integer  "ts_year",                   limit: 4
    t.integer  "ts_quarter",                limit: 4
    t.integer  "course_branch",             limit: 4
    t.integer  "course_no",                 limit: 4
    t.string   "dept_abbrev",               limit: 255
    t.string   "section_id",                limit: 255
    t.date     "start_date"
    t.date     "end_date"
    t.string   "type",                      limit: 255
    t.integer  "activity_course_id",        limit: 4
    t.integer  "activity_type_id",          limit: 4
    t.string   "preparer_uw_netid",         limit: 255
    t.string   "notes",                     limit: 255
    t.decimal  "hours_per_week",                        precision: 10, scale: 2
    t.string   "faculty_uw_netid",          limit: 255
    t.string   "department_name",           limit: 255
    t.string   "faculty_name",              limit: 255
    t.integer  "system_key",                limit: 4
    t.decimal  "number_of_hours",                       precision: 10, scale: 2
    t.integer  "reporting_department_id",   limit: 4
    t.string   "reporting_department_name", limit: 255
  end

  create_table "activity_quarters", force: :cascade do |t|
    t.integer  "quarter_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "hours_per_week",            precision: 10, scale: 2
    t.decimal  "number_of_hours",           precision: 10, scale: 2
    t.integer  "activity_id",     limit: 4
  end

  create_table "activity_types", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.string   "abbreviation", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_interviews", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_answers", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.integer  "offering_question_id",        limit: 4
    t.text     "answer",                      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
    t.integer  "offering_question_option_id", limit: 4
  end

  add_index "application_answers", ["application_for_offering_id"], name: "index_application_answers_on_application_for_offering_id", using: :btree
  add_index "application_answers", ["offering_question_id"], name: "index_application_answers_on_offering_question_id", using: :btree

  create_table "application_awards", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.integer  "requested_quarter_id",        limit: 4
    t.float    "amount_requested",            limit: 24
    t.string   "amount_requested_notes",      limit: 255
    t.float    "amount_approved",             limit: 24
    t.string   "amount_approved_notes",       limit: 255
    t.integer  "amount_approved_user_id",     limit: 4
    t.float    "amount_awarded",              limit: 24
    t.string   "amount_awarded_notes",        limit: 255
    t.integer  "amount_awarded_user_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount_disbersed",            limit: 24
    t.string   "amount_disbersed_notes",      limit: 255
    t.integer  "amount_disbersed_user_id",    limit: 4
    t.integer  "disbersement_type_id",        limit: 4
    t.integer  "disbersement_quarter_id",     limit: 4
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
  end

  add_index "application_awards", ["application_for_offering_id"], name: "index_awards_on_app_id", using: :btree

  create_table "application_categories", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_files", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.string   "title",                       limit: 255
    t.text     "description",                 limit: 65535
    t.integer  "offering_question_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text_version",                limit: 65535
    t.string   "file",                        limit: 255
    t.string   "file_content_type",           limit: 255
    t.string   "file_size",                   limit: 255
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
    t.string   "original_filename",           limit: 255
  end

  create_table "application_final_decision_types", force: :cascade do |t|
    t.string   "title",                      limit: 255
    t.integer  "application_status_type_id", limit: 4
    t.boolean  "yes_option"
    t.integer  "offering_id",                limit: 4
    t.integer  "creator_id",                 limit: 4
    t.integer  "updater_id",                 limit: 4
    t.integer  "deleter_id",                 limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_for_offerings", force: :cascade do |t|
    t.integer  "offering_id",                            limit: 4
    t.integer  "person_id",                              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "selection_committee_access_ok"
    t.boolean  "mentor_access_ok"
    t.string   "local_or_permanent_address",             limit: 255
    t.string   "project_title",                          limit: 255
    t.text     "project_description",                    limit: 65535
    t.string   "hours_per_week",                         limit: 255
    t.integer  "how_did_you_hear_id",                    limit: 4
    t.string   "electronic_signature",                   limit: 255
    t.date     "electronic_signature_date"
    t.text     "special_notes",                          limit: 65535
    t.integer  "current_page_id",                        limit: 4
    t.boolean  "submitted"
    t.boolean  "awarded"
    t.boolean  "contingency"
    t.boolean  "not_awarded"
    t.string   "project_dates",                          limit: 255
    t.text     "other_scholarship_support",              limit: 65535
    t.integer  "feedback_person_id",                     limit: 4
    t.text     "review_committee_notes",                 limit: 65535
    t.text     "interview_committee_notes",              limit: 65535
    t.integer  "application_review_decision_type_id",    limit: 4
    t.text     "project_summary",                        limit: 65535
    t.integer  "interview_feedback_person_id",           limit: 4
    t.integer  "application_interview_decision_type_id", limit: 4
    t.text     "contingency_terms",                      limit: 65535
    t.date     "contingency_checkin_date"
    t.integer  "creator_id",                             limit: 4
    t.integer  "updater_id",                             limit: 4
    t.integer  "deleter_id",                             limit: 4
    t.text     "how_did_you_hear",                       limit: 65535
    t.integer  "current_application_status_id",          limit: 4
    t.datetime "awarded_at"
    t.datetime "approved_at"
    t.datetime "financial_aid_approved_at"
    t.datetime "disbursed_at"
    t.datetime "closed_at"
    t.text     "award_letter_text",                      limit: 65535
    t.datetime "award_letter_sent_at"
    t.datetime "feedback_meeting_date"
    t.integer  "feedback_meeting_person_id",             limit: 4
    t.text     "feedback_meeting_comments",              limit: 65535
    t.integer  "application_type_id",                    limit: 4
    t.integer  "application_category_id",                limit: 4
    t.boolean  "worked_with_mentor"
    t.boolean  "attended_info_session"
    t.boolean  "attended_advising_appointment"
    t.boolean  "attended_feedback_appointment"
    t.string   "other_category_title",                   limit: 255
    t.integer  "offering_session_id",                    limit: 4
    t.integer  "application_moderator_decision_type_id", limit: 4
    t.text     "moderator_comments",                     limit: 65535
    t.integer  "offering_session_order",                 limit: 4
    t.boolean  "confirmed"
    t.text     "theme_response",                         limit: 65535
    t.integer  "nominated_mentor_id",                    limit: 4
    t.text     "nominated_mentor_explanation",           limit: 65535
    t.text     "theme_response2",                        limit: 65535
    t.text     "review_comments",                        limit: 65535
    t.boolean  "requests_printed_program"
    t.integer  "location_section_id",                    limit: 4
    t.integer  "easel_number",                           limit: 4
    t.string   "mentor_department",                      limit: 255
    t.boolean  "lock_easel_number"
    t.integer  "application_final_decision_type_id",     limit: 4
    t.text     "final_committee_notes",                  limit: 65535
    t.boolean  "declined"
    t.text     "acceptance_response1",                   limit: 65535
    t.text     "acceptance_response2",                   limit: 65535
    t.text     "acceptance_response3",                   limit: 65535
    t.datetime "award_accepted_at"
    t.text     "special_requests",                       limit: 65535
    t.text     "task_completion_status_cache",           limit: 65535
    t.integer  "theme_response3",                        limit: 4
  end

  add_index "application_for_offerings", ["offering_id"], name: "index_applications_on_offering_id", using: :btree
  add_index "application_for_offerings", ["person_id"], name: "index_application_for_offerings_on_person_id", using: :btree

  create_table "application_group_members", force: :cascade do |t|
    t.integer  "application_for_offering_id",  limit: 4
    t.integer  "person_id",                    limit: 4
    t.boolean  "verified"
    t.string   "email",                        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "firstname",                    limit: 255
    t.string   "lastname",                     limit: 255
    t.boolean  "uw_student"
    t.datetime "validation_email_sent_at"
    t.integer  "nominated_mentor_id",          limit: 4
    t.text     "nominated_mentor_explanation", limit: 65535
    t.boolean  "confirmed"
    t.text     "theme_response",               limit: 65535
    t.text     "theme_response2",              limit: 65535
    t.boolean  "requests_printed_program"
    t.text     "task_completion_status_cache", limit: 65535
    t.integer  "theme_response3",              limit: 4
  end

  create_table "application_guests", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.integer  "group_member_id",             limit: 4
    t.integer  "application_mentor_id",       limit: 4
    t.string   "firstname",                   limit: 255
    t.string   "lastname",                    limit: 255
    t.text     "address_block",               limit: 65535
    t.boolean  "uw_campus"
    t.datetime "invitation_mailed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "postcard_text",               limit: 65535
  end

  create_table "application_interview_decision_types", force: :cascade do |t|
    t.string   "title",                      limit: 255
    t.integer  "application_status_type_id", limit: 4
    t.boolean  "yes_option"
    t.boolean  "contingency_option"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                 limit: 4
    t.integer  "updater_id",                 limit: 4
    t.integer  "deleter_id",                 limit: 4
    t.integer  "offering_id",                limit: 4
  end

  create_table "application_interviewers", force: :cascade do |t|
    t.integer  "application_for_offering_id",  limit: 4
    t.integer  "offering_interviewer_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comments",                     limit: 65535
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
    t.integer  "deleter_id",                   limit: 4
    t.text     "task_completion_status_cache", limit: 65535
  end

  create_table "application_mentor_answers", force: :cascade do |t|
    t.integer  "application_mentor_id",       limit: 4
    t.integer  "offering_mentor_question_id", limit: 4
    t.text     "answer",                      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_mentor_types", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_mentors", force: :cascade do |t|
    t.integer  "application_for_offering_id",  limit: 4
    t.integer  "person_id",                    limit: 4
    t.boolean  "primary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "waive_access_review_right"
    t.string   "firstname",                    limit: 255
    t.string   "lastname",                     limit: 255
    t.string   "email",                        limit: 255
    t.boolean  "no_email"
    t.string   "token",                        limit: 255
    t.string   "letter",                       limit: 255
    t.string   "letter_content_type",          limit: 255
    t.string   "letter_size",                  limit: 255
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
    t.integer  "deleter_id",                   limit: 4
    t.datetime "invite_email_sent_at"
    t.string   "email_confirmation",           limit: 255
    t.text     "mentor_letter_text",           limit: 65535
    t.datetime "mentor_letter_sent_at"
    t.integer  "application_mentor_type_id",   limit: 4
    t.string   "approval_response",            limit: 255
    t.text     "approval_comments",            limit: 65535
    t.datetime "approval_at"
    t.string   "title",                        limit: 255
    t.string   "relationship",                 limit: 255
    t.text     "task_completion_status_cache", limit: 65535
    t.string   "academic_department",          limit: 255
  end

  add_index "application_mentors", ["application_for_offering_id"], name: "index_mentors_on_app_id", using: :btree
  add_index "application_mentors", ["person_id"], name: "index_mentors_on_person_id", using: :btree

  create_table "application_moderator_decision_types", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.boolean  "yes_option"
    t.integer  "offering_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_other_awards", force: :cascade do |t|
    t.string   "title",                        limit: 255
    t.boolean  "secured"
    t.float    "amount",                       limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "application_for_offering_id",  limit: 4
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
    t.integer  "deleter_id",                   limit: 4
    t.integer  "offering_other_award_type_id", limit: 4
    t.integer  "award_quarter_id",             limit: 4
  end

  create_table "application_pages", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.integer  "offering_page_id",            limit: 4
    t.boolean  "complete"
    t.boolean  "started"
    t.boolean  "passed_validations"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
  end

  add_index "application_pages", ["application_for_offering_id"], name: "index_pages_on_app_id", using: :btree

  create_table "application_review_decision_types", force: :cascade do |t|
    t.string   "title",                      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "application_status_type_id", limit: 4
    t.boolean  "yes_option"
    t.integer  "creator_id",                 limit: 4
    t.integer  "updater_id",                 limit: 4
    t.integer  "deleter_id",                 limit: 4
    t.integer  "offering_id",                limit: 4
  end

  create_table "application_reviewer_scores", force: :cascade do |t|
    t.integer  "application_reviewer_id",      limit: 4
    t.integer  "offering_review_criterion_id", limit: 4
    t.integer  "score",                        limit: 4
    t.text     "comments",                     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "application_reviewer_scores", ["application_reviewer_id"], name: "index_application_reviewer_scores_on_application_reviewer_id", using: :btree
  add_index "application_reviewer_scores", ["offering_review_criterion_id"], name: "offering_review_criterion_index", using: :btree

  create_table "application_reviewers", force: :cascade do |t|
    t.integer  "application_for_offering_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offering_reviewer_id",         limit: 4
    t.text     "comments",                     limit: 65535
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
    t.integer  "deleter_id",                   limit: 4
    t.integer  "committee_member_id",          limit: 4
    t.boolean  "finalized"
    t.boolean  "committee_score"
    t.text     "task_completion_status_cache", limit: 65535
  end

  add_index "application_reviewers", ["application_for_offering_id"], name: "index_reviewers_on_app_id", using: :btree
  add_index "application_reviewers", ["committee_member_id"], name: "index_reviewers_on_committee_member_id", using: :btree
  add_index "application_reviewers", ["offering_reviewer_id"], name: "index_reviewers_on_offering_reviewer_id", using: :btree

  create_table "application_status_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",  limit: 4
    t.integer  "updater_id",  limit: 4
    t.integer  "deleter_id",  limit: 4
  end

  create_table "application_statuses", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.integer  "application_status_type_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
  end

  add_index "application_statuses", ["application_for_offering_id"], name: "index_statuses_on_app_id", using: :btree

  create_table "application_text_versions", force: :cascade do |t|
    t.integer  "application_text_id", limit: 4
    t.text     "text",                limit: 65535
    t.text     "comments",            limit: 65535
    t.integer  "updater_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "application_text_versions", ["application_text_id"], name: "index_text_versions_on_text_id", using: :btree

  create_table "application_texts", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.string   "title",                       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "application_types", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "appointments", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "staff_person_id",         limit: 4
    t.integer  "student_id",              limit: 4
    t.datetime "check_in_time"
    t.integer  "unit_id",                 limit: 4
    t.text     "notes",                   limit: 65535
    t.text     "follow_up_notes",         limit: 65535
    t.integer  "previous_appointment_id", limit: 4
    t.boolean  "drop_in"
    t.string   "type",                    limit: 255
    t.text     "front_desk_notes",        limit: 65535
    t.string   "source",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "contact_type_id",         limit: 4
  end

  add_index "appointments", ["previous_appointment_id"], name: "index_appointments_on_previous_appointment_id", using: :btree
  add_index "appointments", ["staff_person_id"], name: "index_appointments_on_staff_person_id", using: :btree
  add_index "appointments", ["student_id"], name: "index_appointments_on_student_id", using: :btree

  create_table "award_types", force: :cascade do |t|
    t.string   "title",         limit: 255
    t.integer  "unit_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scholar_title", limit: 255
  end

  create_table "changes", force: :cascade do |t|
    t.integer  "change_loggable_id",   limit: 4
    t.string   "change_loggable_type", limit: 255
    t.text     "changes",              limit: 65535
    t.integer  "creator_id",           limit: 4
    t.integer  "updater_id",           limit: 4
    t.integer  "deleter_id",           limit: 4
    t.string   "action_type",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "changes", ["change_loggable_id", "change_loggable_type"], name: "index_changes_on_changable", using: :btree

  create_table "class_standings", force: :cascade do |t|
    t.string   "abbreviation", limit: 255
    t.string   "description",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coalitions", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.integer  "creator_id", limit: 4
    t.integer  "updater_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "coalitions_organizations", force: :cascade do |t|
    t.integer  "organization_id", limit: 4
    t.integer  "coalition_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",      limit: 4
    t.integer  "updater_id",      limit: 4
  end

  create_table "committee_meetings", force: :cascade do |t|
    t.integer  "committee_id", limit: 4
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "title",        limit: 255
    t.text     "description",  limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location",     limit: 255
  end

  create_table "committee_member_meetings", force: :cascade do |t|
    t.integer  "committee_member_id",  limit: 4
    t.integer  "committee_meeting_id", limit: 4
    t.boolean  "attending"
    t.text     "comment",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committee_member_quarters", force: :cascade do |t|
    t.integer  "committee_member_id",  limit: 4
    t.integer  "committee_quarter_id", limit: 4
    t.boolean  "active"
    t.text     "comment",              limit: 65535
    t.integer  "creator_id",           limit: 4
    t.integer  "updater_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "committee_member_types", force: :cascade do |t|
    t.integer  "committee_id",                          limit: 4
    t.string   "name",                                  limit: 255
    t.integer  "creator_id",                            limit: 4
    t.integer  "updater_id",                            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "max_number_of_applicants_per_reviewer", limit: 4
    t.text     "extra_instructions",                    limit: 65535
    t.string   "extra_instructions_link_text",          limit: 255
  end

  create_table "committee_members", force: :cascade do |t|
    t.integer  "committee_id",                 limit: 4
    t.integer  "person_id",                    limit: 4
    t.integer  "committee_member_type_id",     limit: 4
    t.string   "expertise",                    limit: 255
    t.string   "website_url",                  limit: 255
    t.integer  "recommender_id",               limit: 4
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "inactive"
    t.boolean  "permanently_inactive"
    t.text     "comment",                      limit: 65535
    t.text     "notes",                        limit: 65535
    t.datetime "last_user_response_at"
    t.string   "department",                   limit: 255
    t.text     "replacement_recommendation",   limit: 65535
    t.string   "status_cache",                 limit: 255
    t.text     "task_completion_status_cache", limit: 65535
  end

  create_table "committee_quarters", force: :cascade do |t|
    t.integer  "committee_id",         limit: 4
    t.integer  "quarter_id",           limit: 4
    t.integer  "creator_id",           limit: 4
    t.integer  "updater_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "comments_prompt_text", limit: 255
    t.string   "alternate_title",      limit: 255
  end

  create_table "committees", force: :cascade do |t|
    t.string   "name",                             limit: 255
    t.integer  "creator_id",                       limit: 4
    t.integer  "updater_id",                       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "intro_text",                       limit: 65535
    t.text     "inactive_text",                    limit: 65535
    t.text     "complete_text",                    limit: 65535
    t.string   "active_action_text",               limit: 255
    t.text     "unit_signature",                   limit: 65535
    t.boolean  "show_permanently_inactive_option"
    t.boolean  "ask_for_replacement"
    t.date     "response_reset_date"
    t.text     "meetings_text",                    limit: 65535
    t.integer  "interview_offering_id",            limit: 4
  end

  create_table "contact_histories", force: :cascade do |t|
    t.integer  "person_id",                   limit: 4
    t.text     "type",                        limit: 65535
    t.text     "email",                       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
    t.integer  "application_status_id",       limit: 4
    t.integer  "original_contact_history_id", limit: 4
    t.string   "contactable_type",            limit: 255
    t.integer  "contactable_id",              limit: 4
  end

  add_index "contact_histories", ["application_status_id"], name: "application_status_id", using: :btree
  add_index "contact_histories", ["contactable_id"], name: "index_contact_histories_on_contactable_id", using: :btree
  add_index "contact_histories", ["contactable_type"], name: "index_contact_histories_on_contactable_type", using: :btree
  add_index "contact_histories", ["creator_id"], name: "index_contact_histories_on_creator_id", using: :btree
  add_index "contact_histories", ["original_contact_history_id"], name: "original_contact_history_index", using: :btree
  add_index "contact_histories", ["person_id"], name: "index_contact_histories_on_person_id", using: :btree

  create_table "contact_types", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id", limit: 4
    t.integer  "updater_id", limit: 4
  end

  create_table "course_extra_enrollees", force: :cascade do |t|
    t.integer  "ts_year",       limit: 4
    t.integer  "ts_quarter",    limit: 4
    t.integer  "course_branch", limit: 4
    t.integer  "course_no",     limit: 4
    t.string   "dept_abbrev",   limit: 255
    t.string   "section_id",    limit: 255
    t.integer  "person_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",    limit: 4
    t.integer  "updater_id",    limit: 4
  end

  add_index "course_extra_enrollees", ["person_id"], name: "index_course_extra_enrollees_on_person_id", using: :btree
  add_index "course_extra_enrollees", ["ts_year", "ts_quarter", "course_branch", "course_no", "dept_abbrev", "section_id"], name: "course_id_index", using: :btree

  create_table "dashboard_items", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.text     "content",    limit: 65535
    t.string   "icon",       limit: 255
    t.string   "css_class",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "deleted_application_answers", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.integer  "offering_question_id",        limit: 4
    t.text     "answer",                      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
    t.datetime "deleted_at"
    t.integer  "offering_question_option_id", limit: 4
  end

  create_table "deleted_application_awards", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.integer  "requested_quarter_id",        limit: 4
    t.float    "amount_requested",            limit: 24
    t.string   "amount_requested_notes",      limit: 255
    t.float    "amount_approved",             limit: 24
    t.string   "amount_approved_notes",       limit: 255
    t.integer  "amount_approved_user_id",     limit: 4
    t.float    "amount_awarded",              limit: 24
    t.string   "amount_awarded_notes",        limit: 255
    t.integer  "amount_awarded_user_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "amount_disbersed",            limit: 24
    t.string   "amount_disbersed_notes",      limit: 255
    t.integer  "amount_disbersed_user_id",    limit: 4
    t.integer  "disbersement_type_id",        limit: 4
    t.integer  "disbersement_quarter_id",     limit: 4
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
    t.datetime "deleted_at"
  end

  create_table "deleted_application_files", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.string   "title",                       limit: 255
    t.text     "description",                 limit: 65535
    t.integer  "offering_question_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text_version",                limit: 65535
    t.string   "file",                        limit: 255
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
    t.string   "original_filename",           limit: 255
    t.datetime "deleted_at"
    t.string   "file_content_type",           limit: 255
    t.string   "file_size",                   limit: 255
  end

  create_table "deleted_application_for_offerings", force: :cascade do |t|
    t.integer  "offering_id",                            limit: 4
    t.integer  "person_id",                              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "selection_committee_access_ok"
    t.boolean  "mentor_access_ok"
    t.string   "local_or_permanent_address",             limit: 255
    t.string   "project_title",                          limit: 255
    t.text     "project_description",                    limit: 65535
    t.string   "hours_per_week",                         limit: 255
    t.integer  "how_did_you_hear_id",                    limit: 4
    t.string   "electronic_signature",                   limit: 255
    t.date     "electronic_signature_date"
    t.text     "special_notes",                          limit: 65535
    t.integer  "current_page_id",                        limit: 4
    t.boolean  "submitted"
    t.boolean  "awarded"
    t.boolean  "contingency"
    t.boolean  "not_awarded"
    t.string   "project_dates",                          limit: 255
    t.text     "other_scholarship_support",              limit: 65535
    t.integer  "feedback_person_id",                     limit: 4
    t.text     "review_committee_notes",                 limit: 65535
    t.text     "interview_committee_notes",              limit: 65535
    t.integer  "application_review_decision_type_id",    limit: 4
    t.text     "project_summary",                        limit: 65535
    t.integer  "interview_feedback_person_id",           limit: 4
    t.integer  "application_interview_decision_type_id", limit: 4
    t.text     "contingency_terms",                      limit: 65535
    t.date     "contingency_checkin_date"
    t.integer  "creator_id",                             limit: 4
    t.integer  "updater_id",                             limit: 4
    t.integer  "deleter_id",                             limit: 4
    t.text     "how_did_you_hear",                       limit: 65535
    t.datetime "deleted_at"
    t.integer  "current_application_status_id",          limit: 4
    t.datetime "awarded_at"
    t.datetime "financial_aid_approved_at"
    t.datetime "closed_at"
    t.text     "award_letter_text",                      limit: 65535
    t.datetime "approved_at"
    t.datetime "disbursed_at"
    t.datetime "award_letter_sent_at"
    t.datetime "feedback_meeting_date"
    t.integer  "application_category_id",                limit: 4
    t.integer  "application_type_id",                    limit: 4
    t.text     "feedback_meeting_comments",              limit: 65535
    t.integer  "feedback_meeting_person_id",             limit: 4
    t.boolean  "attended_feedback_appointment"
    t.boolean  "attended_advising_appointment"
    t.boolean  "attended_info_session"
    t.boolean  "worked_with_mentor"
    t.string   "other_category_title",                   limit: 255
    t.text     "nominated_mentor_explanation",           limit: 65535
    t.text     "theme_response",                         limit: 65535
    t.integer  "offering_session_order",                 limit: 4
    t.boolean  "confirmed"
    t.text     "moderator_comments",                     limit: 65535
    t.integer  "nominated_mentor_id",                    limit: 4
    t.integer  "offering_session_id",                    limit: 4
    t.text     "review_comments",                        limit: 65535
    t.text     "theme_response2",                        limit: 65535
    t.integer  "application_moderator_decision_type_id", limit: 4
    t.boolean  "lock_easel_number"
    t.integer  "easel_number",                           limit: 4
    t.string   "mentor_department",                      limit: 255
    t.integer  "location_section_id",                    limit: 4
    t.boolean  "requests_printed_program"
    t.text     "acceptance_response3",                   limit: 65535
    t.boolean  "declined"
    t.integer  "application_final_decision_type_id",     limit: 4
    t.text     "final_committee_notes",                  limit: 65535
    t.datetime "award_accepted_at"
    t.text     "acceptance_response1",                   limit: 65535
    t.text     "acceptance_response2",                   limit: 65535
    t.text     "special_requests",                       limit: 65535
    t.text     "task_completion_status_cache",           limit: 65535
    t.integer  "theme_response3",                        limit: 4
  end

  create_table "deleted_application_mentors", force: :cascade do |t|
    t.integer  "application_for_offering_id",  limit: 4
    t.integer  "person_id",                    limit: 4
    t.boolean  "primary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "waive_access_review_right"
    t.string   "firstname",                    limit: 255
    t.string   "lastname",                     limit: 255
    t.string   "email",                        limit: 255
    t.boolean  "no_email"
    t.string   "token",                        limit: 255
    t.string   "letter",                       limit: 255
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
    t.integer  "deleter_id",                   limit: 4
    t.datetime "invite_email_sent_at"
    t.string   "email_confirmation",           limit: 255
    t.datetime "deleted_at"
    t.text     "mentor_letter_text",           limit: 65535
    t.string   "letter_size",                  limit: 255
    t.string   "letter_content_type",          limit: 255
    t.datetime "mentor_letter_sent_at"
    t.integer  "application_mentor_type_id",   limit: 4
    t.datetime "approval_at"
    t.string   "approval_response",            limit: 255
    t.text     "approval_comments",            limit: 65535
    t.string   "title",                        limit: 255
    t.string   "relationship",                 limit: 255
    t.text     "task_completion_status_cache", limit: 65535
    t.string   "academic_department",          limit: 255
  end

  create_table "deleted_application_statuses", force: :cascade do |t|
    t.integer  "application_for_offering_id", limit: 4
    t.integer  "application_status_type_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
    t.datetime "deleted_at"
  end

  create_table "deleted_organization_contacts", force: :cascade do |t|
    t.integer  "person_id",                        limit: 4
    t.integer  "organization_id",                  limit: 4
    t.boolean  "americorps"
    t.date     "americorps_term_end_date"
    t.boolean  "service_learning_contact"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                       limit: 4
    t.integer  "updater_id",                       limit: 4
    t.datetime "deleted_at"
    t.boolean  "primary_service_learning_contact"
    t.boolean  "current"
    t.boolean  "pipeline_contact"
    t.text     "note",                             limit: 65535
  end

  create_table "deleted_organization_quarters", force: :cascade do |t|
    t.integer  "organization_id",             limit: 4
    t.integer  "quarter_id",                  limit: 4
    t.boolean  "active"
    t.integer  "staff_contact_user_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.boolean  "allow_position_edits"
    t.boolean  "allow_evals"
    t.datetime "deleted_at"
    t.integer  "unit_id",                     limit: 4
    t.integer  "in_progress_positions_count", limit: 4
    t.integer  "pending_positions_count",     limit: 4
    t.integer  "approved_positions_count",    limit: 4
    t.boolean  "finished_evaluation"
  end

  create_table "deleted_organizations", force: :cascade do |t|
    t.string   "name",                                limit: 255
    t.integer  "default_location_id",                 limit: 4
    t.integer  "parent_organization_id",              limit: 4
    t.string   "mailing_line_1",                      limit: 255
    t.string   "mailing_line_2",                      limit: 255
    t.string   "mailing_city",                        limit: 255
    t.string   "mailing_state",                       limit: 255
    t.string   "mailing_zip",                         limit: 255
    t.string   "website_url",                         limit: 255
    t.string   "main_phone",                          limit: 255
    t.text     "mission_statement",                   limit: 65535
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                          limit: 4
    t.integer  "updater_id",                          limit: 4
    t.integer  "primary_service_learning_contact_id", limit: 4
    t.datetime "deleted_at"
    t.boolean  "inactive"
    t.boolean  "archive"
    t.boolean  "does_service_learning"
    t.integer  "next_active_quarter_id",              limit: 4
    t.integer  "school_type_id",                      limit: 4
    t.boolean  "target_school"
    t.string   "type",                                limit: 255
    t.boolean  "does_pipeline"
    t.boolean  "multiple_quarter"
  end

  create_table "deleted_service_learning_courses", force: :cascade do |t|
    t.string   "alternate_title",          limit: 255
    t.string   "quarter_id",               limit: 255
    t.string   "syllabus",                 limit: 255
    t.string   "syllabus_url",             limit: 255
    t.text     "overview",                 limit: 65535
    t.text     "role_of_service_learning", limit: 65535
    t.text     "assignments",              limit: 65535
    t.datetime "presentation_time"
    t.integer  "presentation_length",      limit: 4
    t.boolean  "finalized"
    t.datetime "registration_open_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",               limit: 4
    t.integer  "updater_id",               limit: 4
    t.datetime "deleted_at"
    t.integer  "unit_id",                  limit: 4
    t.text     "students",                 limit: 65535
    t.boolean  "no_filters"
    t.integer  "pipeline_student_type_id", limit: 4
    t.boolean  "required"
    t.boolean  "general_study"
  end

  create_table "deleted_service_learning_orientations", force: :cascade do |t|
    t.datetime "start_time"
    t.integer  "location_id",                    limit: 4
    t.boolean  "flexible"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                     limit: 4
    t.integer  "updater_id",                     limit: 4
    t.text     "notes",                          limit: 65535
    t.datetime "deleted_at"
    t.boolean  "different_orientation_contact"
    t.boolean  "different_orientation_location"
    t.integer  "organization_contact_id",        limit: 4
  end

  create_table "deleted_service_learning_placements", force: :cascade do |t|
    t.integer  "person_id",                    limit: 4
    t.integer  "service_learning_position_id", limit: 4
    t.integer  "service_learning_course_id",   limit: 4
    t.datetime "waiver_date"
    t.string   "waiver_signature",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
    t.datetime "deleted_at"
    t.integer  "confirmation_history_id",      limit: 4
    t.datetime "confirmed_at"
    t.integer  "quarter_update_history_id",    limit: 4
    t.integer  "unit_id",                      limit: 4
    t.datetime "tutoring_submitted_at"
  end

  create_table "deleted_service_learning_position_times", force: :cascade do |t|
    t.integer  "service_learning_position_id", limit: 4
    t.time     "start_time"
    t.time     "end_time"
    t.boolean  "flexible"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
    t.datetime "deleted_at"
  end

  create_table "deleted_service_learning_positions", force: :cascade do |t|
    t.string   "title",                                 limit: 255
    t.integer  "organization_quarter_id",               limit: 4
    t.integer  "location_id",                           limit: 4
    t.text     "description",                           limit: 65535
    t.string   "age_requirement",                       limit: 255
    t.string   "duration_requirement",                  limit: 255
    t.text     "alternate_transportation",              limit: 65535
    t.integer  "previous_service_learning_position_id", limit: 4
    t.integer  "supervisor_person_id",                  limit: 4
    t.text     "time_notes",                            limit: 65535
    t.integer  "service_learning_orientation_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                            limit: 4
    t.integer  "updater_id",                            limit: 4
    t.boolean  "self_placement"
    t.boolean  "approved"
    t.datetime "deleted_at"
    t.text     "context_description",                   limit: 65535
    t.integer  "ideal_number_of_slots",                 limit: 4
    t.text     "impact_description",                    limit: 65535
    t.string   "time_commitment_requirement",           limit: 255
    t.text     "paperwork_requirement",                 limit: 65535
    t.boolean  "tb_test_required"
    t.boolean  "in_progress"
    t.boolean  "background_check_required"
    t.text     "skills_requirement",                    limit: 65535
    t.boolean  "times_are_flexible"
    t.text     "other_duration_requirement",            limit: 65535
    t.text     "other_age_requirement",                 limit: 65535
    t.integer  "bus_trip_time",                         limit: 4
    t.integer  "unit_id",                               limit: 4
    t.boolean  "use_slots"
    t.integer  "filled_placements_count",               limit: 4
    t.integer  "unallocated_placements_count",          limit: 4
    t.integer  "total_placements_count",                limit: 4
    t.boolean  "general_study"
    t.text     "learning_goals",                        limit: 65535
    t.text     "academic_topics",                       limit: 65535
    t.text     "sources",                               limit: 65535
    t.boolean  "public_service"
    t.integer  "total_hours",                           limit: 4
    t.integer  "credit",                                limit: 4
    t.integer  "volunteer",                             limit: 4
    t.decimal  "compensation",                                        precision: 8, scale: 2
    t.boolean  "flu_vaccination_required"
    t.boolean  "food_permit_required"
    t.boolean  "other_health_required"
    t.string   "other_health_requirement",              limit: 255
    t.boolean  "legal_name_required"
    t.boolean  "birthdate_required"
    t.boolean  "ssn_required"
    t.boolean  "fingerprint_required"
    t.boolean  "other_background_check_required"
    t.string   "other_background_check_requirement",    limit: 255
    t.boolean  "non_intl_student_required"
    t.date     "volunteer_since"
    t.boolean  "paid"
    t.boolean  "religious"
  end

  create_table "department_extras", force: :cascade do |t|
    t.integer  "dept_code",         limit: 4
    t.string   "fixed_name",        limit: 255
    t.string   "chair_name",        limit: 255
    t.string   "chair_email",       limit: 255
    t.string   "chair_title",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "temp_num_students", limit: 4
  end

  add_index "department_extras", ["dept_code"], name: "dept_code", unique: true, using: :btree

  create_table "disbersement_types", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id", limit: 4
    t.integer  "updater_id", limit: 4
    t.integer  "deleter_id", limit: 4
  end

  create_table "discipline_categories", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "email_queues", force: :cascade do |t|
    t.integer  "person_id",                   limit: 4
    t.text     "email",                       limit: 65535
    t.integer  "application_status_type_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
    t.integer  "application_status_id",       limit: 4
    t.text     "command_after_delivery",      limit: 65535
    t.integer  "original_contact_history_id", limit: 4
    t.string   "contactable_type",            limit: 255
    t.integer  "contactable_id",              limit: 4
    t.text     "error_details",               limit: 65535
  end

  create_table "equipment", force: :cascade do |t|
    t.string   "tag",                      limit: 255
    t.string   "title",                    limit: 255
    t.integer  "equipment_category_id",    limit: 4
    t.datetime "warranty_expiration_date"
    t.boolean  "ready_for_checkout"
    t.string   "local_picture",            limit: 255
    t.text     "description",              limit: 65535
    t.boolean  "staff_only"
    t.text     "special_instructions",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "purchase_date"
    t.string   "serial_number",            limit: 255
    t.text     "included_accessories",     limit: 65535
    t.text     "included_software",        limit: 65535
    t.float    "replacement_fee",          limit: 24
    t.string   "inventory_number",         limit: 255
    t.string   "warranty_number",          limit: 255
    t.string   "hardware_address",         limit: 255
  end

  create_table "equipment_categories", force: :cascade do |t|
    t.string   "title",                                            limit: 255
    t.text     "description",                                      limit: 65535
    t.integer  "max_checkout_days",                                limit: 4
    t.text     "staff_instructions",                               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture",                                          limit: 255
    t.integer  "max_items_per_checkout",                           limit: 4,     default: 1
    t.integer  "buffer_days_between_checkouts",                    limit: 4,     default: 1
    t.text     "checkout_instructions",                            limit: 65535
    t.text     "checkin_instructions",                             limit: 65535
    t.boolean  "requires_staff_intervention_before_next_checkout"
    t.boolean  "requires_reimage_before_next_checkout"
    t.string   "as_same_category",                                 limit: 255
  end

  create_table "equipment_reservation_equipments", force: :cascade do |t|
    t.integer  "equipment_reservation_id", limit: 4
    t.integer  "equipment_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "equipment_reservations", force: :cascade do |t|
    t.integer  "person_id",             limit: 4
    t.datetime "policy_agreement_date"
    t.text     "project_description",   limit: 65535
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "unit_id",               limit: 4
    t.integer  "approver_id",           limit: 4
    t.datetime "approved_at"
    t.datetime "checked_out_at"
    t.string   "checkout_id_verify",    limit: 255
    t.integer  "checkout_user_id",      limit: 4
    t.datetime "checked_in_at"
    t.integer  "checkin_user_id",       limit: 4
    t.boolean  "checkin_ok"
    t.text     "checkin_notes",         limit: 65535
    t.boolean  "submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                limit: 255
    t.boolean  "staff"
    t.boolean  "program_hold"
  end

  create_table "evaluation_questions", force: :cascade do |t|
    t.integer  "evaluation_questionable_id",   limit: 4
    t.string   "evaluation_questionable_type", limit: 255
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "question",                     limit: 65535
    t.string   "display_as",                   limit: 255
    t.integer  "sequence",                     limit: 4
    t.boolean  "required"
    t.integer  "unit_id",                      limit: 4
    t.boolean  "general_study"
  end

  create_table "evaluation_responses", force: :cascade do |t|
    t.integer  "evaluation_id",          limit: 4
    t.integer  "evaluation_question_id", limit: 4
    t.text     "response",               limit: 65535
    t.integer  "creator_id",             limit: 4
    t.integer  "updater_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes",                  limit: 65535
  end

  add_index "evaluation_responses", ["evaluation_id"], name: "index_evaluation_responses_on_evaluation_id", using: :btree

  create_table "evaluations", force: :cascade do |t|
    t.integer  "creator_id",          limit: 4
    t.integer  "updater_id",          limit: 4
    t.integer  "evaluatable_id",      limit: 4
    t.string   "evaluatable_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "completer_person_id", limit: 4
    t.string   "completer_name",      limit: 255
    t.text     "completer_reason",    limit: 65535
    t.datetime "submitted_at"
  end

  add_index "evaluations", ["evaluatable_id", "evaluatable_type"], name: "index_evaluations_on_evaluatable", using: :btree

  create_table "event_invitees", force: :cascade do |t|
    t.integer  "event_time_id",    limit: 4
    t.string   "invitable_type",   limit: 255
    t.integer  "invitable_id",     limit: 4
    t.boolean  "attending"
    t.text     "rsvp_comments",    limit: 65535
    t.integer  "number_of_guests", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",       limit: 4
    t.integer  "updater_id",       limit: 4
    t.integer  "sub_time_id",      limit: 4
    t.datetime "checkin_time"
    t.text     "checkin_notes",    limit: 65535
    t.integer  "person_id",        limit: 4
    t.boolean  "mobile_checkin"
  end

  add_index "event_invitees", ["event_time_id"], name: "index_event_invitees_on_event_time_id", using: :btree
  add_index "event_invitees", ["invitable_id", "invitable_type"], name: "index_event_invitees_on_invitable", using: :btree

  create_table "event_staff_position_shifts", force: :cascade do |t|
    t.integer  "event_staff_position_id", limit: 4
    t.datetime "start_time"
    t.datetime "end_time"
    t.text     "details",                 limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_staff_positions", force: :cascade do |t|
    t.integer  "event_id",                  limit: 4
    t.string   "title",                     limit: 255
    t.integer  "capacity",                  limit: 4
    t.text     "description",               limit: 65535
    t.text     "instructions",              limit: 65535
    t.integer  "training_session_event_id", limit: 4
    t.text     "restrictions",              limit: 65535
    t.boolean  "require_all_shifts"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_staffs", force: :cascade do |t|
    t.integer  "event_staff_position_shift_id", limit: 4
    t.integer  "person_id",                     limit: 4
    t.text     "comments",                      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_times", force: :cascade do |t|
    t.integer  "event_id",       limit: 4
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "location_id",    limit: 4
    t.integer  "capacity",       limit: 4
    t.text     "notes",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",     limit: 4
    t.integer  "updater_id",     limit: 4
    t.string   "location_text",  limit: 255
    t.integer  "parent_time_id", limit: 4
    t.string   "type",           limit: 255
    t.string   "title",          limit: 255
    t.string   "facilitator",    limit: 255
  end

  create_table "event_types", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.text     "description", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", force: :cascade do |t|
    t.string   "title",                                      limit: 255
    t.text     "description",                                limit: 65535
    t.boolean  "allow_multiple_times_per_attendee"
    t.integer  "capacity",                                   limit: 4
    t.text     "restrictions",                               limit: 65535
    t.integer  "offering_id",                                limit: 4
    t.integer  "confirmation_email_template_id",             limit: 4
    t.boolean  "allow_guests"
    t.integer  "unit_id",                                    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                                 limit: 4
    t.integer  "updater_id",                                 limit: 4
    t.boolean  "public"
    t.boolean  "allow_multiple_positions_per_staff"
    t.integer  "staff_signup_email_template_id",             limit: 4
    t.text     "extra_fields_to_display",                    limit: 65535
    t.text     "other_nametags",                             limit: 65535
    t.boolean  "show_application_location_in_checkin"
    t.integer  "event_type_id",                              limit: 4
    t.integer  "activity_type_id",                           limit: 4
    t.integer  "pull_accountability_hours_from_application", limit: 4
  end

  create_table "favorite_pages", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "url",        limit: 255
    t.string   "title",      limit: 255
    t.integer  "position",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "general_study_faculties", force: :cascade do |t|
    t.string   "firstname",   limit: 255
    t.string   "lastname",    limit: 255
    t.string   "uw_netid",    limit: 255
    t.string   "code",        limit: 255
    t.string   "employee_id", limit: 255
    t.string   "person_id",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "help_texts", force: :cascade do |t|
    t.string   "type",           limit: 255
    t.string   "key",            limit: 255
    t.string   "object_type",    limit: 255
    t.string   "attribute_name", limit: 255
    t.text     "caption",        limit: 65535
    t.text     "example",        limit: 65535
    t.integer  "creator_id",     limit: 4
    t.integer  "updater_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "tech_note",      limit: 65535
    t.string   "title",          limit: 255
    t.boolean  "plain_text"
  end

  create_table "interview_availabilities", force: :cascade do |t|
    t.integer  "offering_interview_timeblock_id", limit: 4
    t.integer  "application_for_offering_id",     limit: 4
    t.integer  "offering_interviewer_id",         limit: 4
    t.time     "time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                      limit: 4
    t.integer  "updater_id",                      limit: 4
    t.integer  "deleter_id",                      limit: 4
  end

  add_index "interview_availabilities", ["application_for_offering_id"], name: "index_availabilities_on_app_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "title",                     limit: 255
    t.string   "address_line_1",            limit: 255
    t.string   "address_line_2",            limit: 255
    t.string   "address_city",              limit: 255
    t.string   "address_state",             limit: 255
    t.string   "address_zip",               limit: 255
    t.text     "driving_directions",        limit: 65535
    t.text     "bus_directions",            limit: 65535
    t.text     "notes",                     limit: 65535
    t.integer  "site_supervisor_person_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                limit: 4
    t.integer  "updater_id",                limit: 4
    t.integer  "organization_id",           limit: 4
    t.string   "neighborhood",              limit: 255
  end

  create_table "login_histories", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session_id", limit: 255
    t.string   "ip",         limit: 255
  end

  add_index "login_histories", ["session_id"], name: "session_id", using: :btree
  add_index "login_histories", ["user_id"], name: "user_id", using: :btree

  create_table "major_extras", force: :cascade do |t|
    t.integer  "major_branch",           limit: 4
    t.integer  "major_pathway",          limit: 4
    t.integer  "major_last_yr",          limit: 4
    t.integer  "major_last_qtr",         limit: 4
    t.string   "major_abbr",             limit: 255
    t.string   "fixed_name",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "chair_name",             limit: 255
    t.string   "chair_email",            limit: 255
    t.integer  "temp_num_students",      limit: 4
    t.integer  "discipline_category_id", limit: 4
  end

  add_index "major_extras", ["major_branch", "major_pathway", "major_last_yr", "major_last_qtr", "major_abbr"], name: "major_index", using: :btree

  create_table "notes", force: :cascade do |t|
    t.text     "note",            limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",      limit: 4
    t.integer  "updater_id",      limit: 4
    t.integer  "deleter_id",      limit: 4
    t.integer  "contact_type_id", limit: 4
    t.integer  "notable_id",      limit: 4
    t.string   "notable_type",    limit: 255
    t.string   "creator_name",    limit: 255
    t.string   "category",        limit: 255
    t.string   "access_level",    limit: 255
  end

  add_index "notes", ["notable_id", "notable_type"], name: "notable_index", using: :btree

  create_table "offering_admin_phase_task_completion_statuses", force: :cascade do |t|
    t.integer  "task_id",       limit: 4
    t.string   "taskable_type", limit: 255
    t.integer  "taskable_id",   limit: 4
    t.integer  "creator_id",    limit: 4
    t.integer  "updater_id",    limit: 4
    t.text     "result",        limit: 65535
    t.boolean  "complete"
    t.text     "notes",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "offering_admin_phase_task_completion_statuses", ["task_id"], name: "task_id_index", using: :btree
  add_index "offering_admin_phase_task_completion_statuses", ["taskable_type", "taskable_id"], name: "taskable_index", using: :btree

  create_table "offering_admin_phase_task_extra_fields", force: :cascade do |t|
    t.integer  "offering_admin_phase_task_id", limit: 4
    t.string   "title",                        limit: 255
    t.text     "display_method",               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_admin_phase_tasks", force: :cascade do |t|
    t.integer  "offering_admin_phase_id",                  limit: 4
    t.string   "title",                                    limit: 255
    t.boolean  "complete"
    t.integer  "creator_id",                               limit: 4
    t.integer  "updater_id",                               limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_as",                               limit: 255
    t.string   "application_status_types",                 limit: 255
    t.string   "new_application_status_type",              limit: 255
    t.string   "email_templates",                          limit: 255
    t.boolean  "show_history"
    t.integer  "sequence",                                 limit: 4
    t.text     "applicant_list_criteria",                  limit: 65535
    t.text     "reviewer_list_criteria",                   limit: 65535
    t.text     "detail_text",                              limit: 65535
    t.string   "url",                                      limit: 500
    t.text     "notes",                                    limit: 65535
    t.string   "progress_column_title",                    limit: 255
    t.text     "progress_display_criteria",                limit: 65535
    t.string   "context",                                  limit: 255
    t.boolean  "show_for_success"
    t.boolean  "show_for_failure"
    t.boolean  "show_for_in_progress"
    t.text     "completion_criteria",                      limit: 65535
    t.boolean  "show_for_context_object_tasks"
    t.text     "context_object_completion_criteria",       limit: 65535
    t.text     "context_object_progress_display_criteria", limit: 65535
  end

  create_table "offering_admin_phases", force: :cascade do |t|
    t.string   "name",                                 limit: 255
    t.string   "display_as",                           limit: 255
    t.integer  "offering_id",                          limit: 4
    t.integer  "sequence",                             limit: 4
    t.boolean  "complete"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                           limit: 4
    t.integer  "updater_id",                           limit: 4
    t.integer  "deleter_id",                           limit: 4
    t.text     "notes",                                limit: 65535
    t.boolean  "show_progress_completion",                           default: true
    t.boolean  "show_each_status_separately"
    t.text     "in_progress_application_status_types", limit: 65535
    t.text     "success_application_status_types",     limit: 65535
    t.text     "failure_application_status_types",     limit: 65535
  end

  create_table "offering_application_categories", force: :cascade do |t|
    t.integer  "application_category_id",      limit: 4
    t.integer  "offering_id",                  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offering_application_type_id", limit: 4
    t.boolean  "other_option"
    t.integer  "sequence",                     limit: 4
  end

  create_table "offering_application_types", force: :cascade do |t|
    t.integer  "application_type_id",  limit: 4
    t.integer  "offering_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_other_category"
    t.integer  "workshop_event_id",    limit: 4
  end

  create_table "offering_award_types", force: :cascade do |t|
    t.integer  "offering_id",   limit: 4
    t.integer  "award_type_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_committee_member_restrictions", force: :cascade do |t|
    t.integer  "offering_id",              limit: 4
    t.integer  "committee_member_type_id", limit: 4
    t.integer  "min_per_applicant",        limit: 4
    t.integer  "max_applicants_per",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_committee_member_types", force: :cascade do |t|
    t.integer  "offering_id",              limit: 4
    t.integer  "committee_member_type_id", limit: 4
    t.integer  "min_per_applicant",        limit: 4
    t.integer  "max_applicants_per",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_dashboard_items", force: :cascade do |t|
    t.integer  "offering_id",                  limit: 4
    t.integer  "dashboard_item_id",            limit: 4
    t.text     "criteria",                     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sequence",                     limit: 4
    t.boolean  "show_group_members"
    t.integer  "offering_application_type_id", limit: 4
    t.string   "status_lookup_method",         limit: 255
    t.integer  "offering_status_id",           limit: 4
    t.boolean  "disabled"
  end

  create_table "offering_interview_applicants", force: :cascade do |t|
    t.integer  "offering_interview_id",       limit: 4
    t.integer  "application_for_offering_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
  end

  create_table "offering_interview_interviewer_scores", force: :cascade do |t|
    t.integer  "offering_interview_interviewer_id", limit: 4
    t.integer  "offering_review_criterion_id",      limit: 4
    t.integer  "score",                             limit: 4
    t.text     "comments",                          limit: 65535
    t.integer  "creator_id",                        limit: 4
    t.integer  "updater_id",                        limit: 4
    t.integer  "deleter_id",                        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_interview_interviewers", force: :cascade do |t|
    t.integer  "offering_interview_id",   limit: 4
    t.integer  "offering_interviewer_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comments",                limit: 65535
    t.integer  "creator_id",              limit: 4
    t.integer  "updater_id",              limit: 4
    t.integer  "deleter_id",              limit: 4
    t.boolean  "finalized"
    t.boolean  "committee_score"
  end

  create_table "offering_interview_timeblocks", force: :cascade do |t|
    t.integer  "offering_id", limit: 4
    t.date     "date"
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",  limit: 4
    t.integer  "updater_id",  limit: 4
    t.integer  "deleter_id",  limit: 4
  end

  create_table "offering_interviewer_conflict_of_interests", force: :cascade do |t|
    t.integer  "offering_interviewer_id",     limit: 4
    t.integer  "application_for_offering_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
  end

  create_table "offering_interviewers", force: :cascade do |t|
    t.integer  "person_id",                                limit: 4
    t.integer  "offering_id",                              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "special_notes",                            limit: 65535
    t.boolean  "first_time"
    t.boolean  "off_campus"
    t.boolean  "past_scholar"
    t.datetime "interview_times_email_sent_at"
    t.integer  "creator_id",                               limit: 4
    t.integer  "updater_id",                               limit: 4
    t.integer  "deleter_id",                               limit: 4
    t.datetime "invite_email_sent_at"
    t.integer  "invite_email_contact_history_id",          limit: 4
    t.integer  "interview_times_email_contact_history_id", limit: 4
    t.integer  "committee_member_id",                      limit: 4
    t.text     "task_completion_status_cache",             limit: 65535
  end

  create_table "offering_interviews", force: :cascade do |t|
    t.datetime "start_time"
    t.string   "location",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "offering_id", limit: 4
    t.text     "notes",       limit: 65535
    t.integer  "creator_id",  limit: 4
    t.integer  "updater_id",  limit: 4
    t.integer  "deleter_id",  limit: 4
  end

  create_table "offering_invitation_codes", force: :cascade do |t|
    t.integer  "offering_id",                 limit: 4
    t.string   "code",                        limit: 255
    t.integer  "application_for_offering_id", limit: 4
    t.string   "note",                        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "institution_id",              limit: 4
  end

  create_table "offering_location_sections", force: :cascade do |t|
    t.integer  "offering_id",           limit: 4
    t.string   "title",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "starting_easel_number", limit: 4
    t.integer  "ending_easel_number",   limit: 4
    t.string   "color",                 limit: 255
  end

  create_table "offering_mentor_questions", force: :cascade do |t|
    t.integer  "offering_id",    limit: 4
    t.text     "question",       limit: 65535
    t.boolean  "required"
    t.boolean  "must_be_number"
    t.string   "display_as",     limit: 255
    t.integer  "size",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "offering_mentor_types", force: :cascade do |t|
    t.integer  "offering_id",                 limit: 4
    t.integer  "application_mentor_type_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "meets_minimum_qualification"
  end

  create_table "offering_other_award_types", force: :cascade do |t|
    t.integer  "offering_id",                  limit: 4
    t.integer  "award_type_id",                limit: 4
    t.boolean  "ask_for_award_quarter"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "restrict_number_of_awards_to", limit: 4
  end

  create_table "offering_page_types", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",  limit: 4
    t.integer  "updater_id",  limit: 4
    t.integer  "deleter_id",  limit: 4
  end

  create_table "offering_pages", force: :cascade do |t|
    t.integer  "offering_id",           limit: 4
    t.string   "title",                 limit: 255
    t.string   "description",           limit: 255
    t.integer  "ordering",              limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "introduction",          limit: 65535
    t.integer  "creator_id",            limit: 4
    t.integer  "updater_id",            limit: 4
    t.integer  "deleter_id",            limit: 4
    t.boolean  "hide_in_admin_view"
    t.boolean  "hide_in_reviewer_view"
  end

  create_table "offering_question_options", force: :cascade do |t|
    t.integer  "offering_question_id",  limit: 4
    t.string   "value",                 limit: 255
    t.string   "title",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",            limit: 4
    t.integer  "updater_id",            limit: 4
    t.integer  "deleter_id",            limit: 4
    t.integer  "associate_question_id", limit: 4
    t.string   "ordering",              limit: 255
  end

  create_table "offering_question_validations", force: :cascade do |t|
    t.integer "offering_question_id", limit: 4
    t.string  "type",                 limit: 255
    t.string  "parameter",            limit: 255
    t.text    "custom_error_text",    limit: 65535
    t.integer "creator_id",           limit: 4
    t.integer "updater_id",           limit: 4
    t.integer "deleter_id",           limit: 4
  end

  create_table "offering_questions", force: :cascade do |t|
    t.integer  "offering_page_id",           limit: 4
    t.text     "question",                   limit: 65535
    t.integer  "ordering",                   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "required"
    t.string   "validation_criteria",        limit: 255
    t.string   "type",                       limit: 255
    t.boolean  "required_now"
    t.text     "help_text",                  limit: 65535
    t.integer  "character_limit",            limit: 4
    t.integer  "word_limit",                 limit: 4
    t.string   "display_as",                 limit: 255
    t.string   "attribute_to_update",        limit: 255
    t.string   "model_to_update",            limit: 255
    t.string   "parameter1",                 limit: 255
    t.integer  "width",                      limit: 4
    t.integer  "height",                     limit: 4
    t.text     "caption",                    limit: 65535
    t.text     "error_text",                 limit: 65535
    t.string   "short_title",                limit: 255
    t.integer  "creator_id",                 limit: 4
    t.integer  "updater_id",                 limit: 4
    t.integer  "deleter_id",                 limit: 4
    t.string   "help_link_text",             limit: 255
    t.boolean  "use_mce_editor"
    t.boolean  "require_valid_phone_number"
    t.boolean  "require_no_line_breaks"
    t.boolean  "dynamic_answer"
    t.integer  "option_column",              limit: 4
    t.integer  "start_year",                 limit: 4
    t.integer  "end_year",                   limit: 4
  end

  create_table "offering_restriction_exemptions", force: :cascade do |t|
    t.integer  "offering_restriction_id", limit: 4
    t.integer  "person_id",               limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "valid_until"
    t.integer  "creator_id",              limit: 4
    t.integer  "updater_id",              limit: 4
    t.integer  "deleter_id",              limit: 4
    t.text     "note",                    limit: 65535
  end

  create_table "offering_restrictions", force: :cascade do |t|
    t.integer  "offering_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",         limit: 255
    t.text     "extra_detail", limit: 65535
    t.integer  "creator_id",   limit: 4
    t.integer  "updater_id",   limit: 4
    t.integer  "deleter_id",   limit: 4
    t.text     "parameter",    limit: 65535
  end

  create_table "offering_review_criterions", force: :cascade do |t|
    t.integer  "offering_id", limit: 4
    t.string   "title",       limit: 255
    t.integer  "max_score",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description", limit: 65535
    t.integer  "sequence",    limit: 4
  end

  create_table "offering_reviewers", force: :cascade do |t|
    t.integer  "person_id",   limit: 4
    t.integer  "offering_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",  limit: 4
    t.integer  "updater_id",  limit: 4
    t.integer  "deleter_id",  limit: 4
  end

  create_table "offering_sessions", force: :cascade do |t|
    t.integer  "offering_id",                  limit: 4
    t.string   "title",                        limit: 255
    t.integer  "moderator_id",                 limit: 4
    t.text     "moderator_comments",           limit: 65535
    t.string   "location",                     limit: 255
    t.time     "start_time"
    t.time     "end_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "finalized"
    t.datetime "finalized_date"
    t.boolean  "title_is_temporary"
    t.integer  "offering_application_type_id", limit: 4
    t.string   "session_group",                limit: 255
    t.boolean  "uses_location_sections"
    t.string   "identifier",                   limit: 255
    t.integer  "presenters_count",             limit: 4
  end

  create_table "offering_status_emails", force: :cascade do |t|
    t.integer  "offering_status_id",    limit: 4
    t.integer  "email_template_id",     limit: 4
    t.boolean  "auto_send"
    t.string   "send_to",               limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",            limit: 4
    t.integer  "updater_id",            limit: 4
    t.integer  "deleter_id",            limit: 4
    t.boolean  "cc_to_feedback_person"
  end

  create_table "offering_statuses", force: :cascade do |t|
    t.integer  "offering_id",                 limit: 4
    t.integer  "application_status_type_id",  limit: 4
    t.text     "message",                     limit: 65535
    t.string   "public_title",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "disallow_user_edits"
    t.boolean  "disallow_all_edits"
    t.integer  "sequence",                    limit: 4
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.integer  "deleter_id",                  limit: 4
    t.boolean  "allow_application_edits"
    t.boolean  "allow_abstract_revisions"
    t.boolean  "allow_abstract_confirmation"
    t.boolean  "allow_confirmation"
  end

  create_table "offerings", force: :cascade do |t|
    t.string   "name",                                        limit: 255
    t.integer  "unit_id",                                     limit: 4
    t.datetime "open_date"
    t.datetime "deadline"
    t.text     "description",                                 limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name",                                limit: 255
    t.string   "contact_email",                               limit: 255
    t.string   "contact_phone",                               limit: 255
    t.integer  "number_of_awards",                            limit: 4
    t.float    "default_award_amount",                        limit: 24
    t.integer  "max_number_of_mentors",                       limit: 4
    t.integer  "quarter_offered_id",                          limit: 4
    t.text     "final_text",                                  limit: 65535
    t.integer  "min_number_of_awards",                        limit: 4
    t.integer  "max_number_of_awards",                        limit: 4
    t.integer  "min_number_of_mentors",                       limit: 4
    t.integer  "max_quarters_ahead_for_awards",               limit: 4
    t.string   "notify_email",                                limit: 255
    t.text     "mentor_instructions",                         limit: 65535
    t.string   "destroy_by",                                  limit: 255
    t.integer  "interview_time_for_applicants",               limit: 4
    t.integer  "interview_time_for_interviewers",             limit: 4
    t.integer  "dean_approver_id",                            limit: 4
    t.integer  "financial_aid_approver_id",                   limit: 4
    t.integer  "disbersement_approver_id",                    limit: 4
    t.integer  "creator_id",                                  limit: 4
    t.integer  "updater_id",                                  limit: 4
    t.integer  "deleter_id",                                  limit: 4
    t.integer  "current_offering_admin_phase_id",             limit: 4
    t.integer  "review_committee_id",                         limit: 4
    t.integer  "interview_committee_id",                      limit: 4
    t.boolean  "allow_early_mentor_submissions"
    t.integer  "early_mentor_invite_email_template_id",       limit: 4
    t.integer  "mentor_thank_you_email_template_id",          limit: 4
    t.integer  "min_number_of_reviews_per_applicant",         limit: 4
    t.text     "reviewer_instructions",                       limit: 65535
    t.text     "interviewer_instructions",                    limit: 65535
    t.text     "reviewer_help_text",                          limit: 65535
    t.integer  "applicant_award_letter_template_id",          limit: 4
    t.integer  "mentor_award_letter_template_id",             limit: 4
    t.boolean  "uses_interviews"
    t.datetime "financial_aid_approval_request_sent_at"
    t.string   "type",                                        limit: 255
    t.integer  "year_offered",                                limit: 4
    t.boolean  "ask_applicant_to_waive_mentor_access_right"
    t.boolean  "allow_hard_copy_letters_from_mentors"
    t.integer  "group_member_validation_email_template_id",   limit: 4
    t.string   "alternate_stylesheet",                        limit: 255
    t.boolean  "allow_students_only"
    t.string   "mentor_mode",                                 limit: 255
    t.boolean  "require_invitation_codes_from_non_students"
    t.text     "revise_abstract_instructions",                limit: 65535
    t.integer  "moderator_committee_id",                      limit: 4
    t.text     "moderator_instructions",                      limit: 65535
    t.text     "moderator_criteria",                          limit: 65535
    t.boolean  "uses_non_committee_review"
    t.text     "confirmation_instructions",                   limit: 65535
    t.text     "confirmation_yes_text",                       limit: 65535
    t.text     "guest_invitation_instructions",               limit: 65535
    t.text     "guest_postcard_layout",                       limit: 65535
    t.text     "theme_response_instructions",                 limit: 65535
    t.text     "nomination_instructions",                     limit: 65535
    t.string   "theme_response_title",                        limit: 255
    t.string   "theme_response2_instructions",                limit: 255
    t.string   "theme_response_type",                         limit: 255
    t.string   "theme_response2_type",                        limit: 255
    t.integer  "theme_response_word_limit",                   limit: 4
    t.integer  "theme_response2_word_limit",                  limit: 4
    t.text     "notes",                                       limit: 65535
    t.boolean  "disable_confirmation"
    t.integer  "application_for_offerings_count",             limit: 4
    t.integer  "first_eligible_award_quarter_id",             limit: 4
    t.boolean  "uses_moderators"
    t.boolean  "uses_mentors",                                              default: true
    t.string   "reviewer_past_application_access",            limit: 255
    t.boolean  "uses_group_members"
    t.boolean  "uses_awards",                                               default: true
    t.boolean  "uses_confirmation"
    t.boolean  "require_all_mentor_letters_before_complete"
    t.boolean  "review_committee_submits_committee_score"
    t.boolean  "interview_committee_submits_committee_score"
    t.boolean  "uses_scored_interviews"
    t.text     "interviewer_help_text",                       limit: 65535
    t.string   "alternate_mentor_title",                      limit: 255
    t.boolean  "ask_for_mentor_relationship"
    t.boolean  "ask_for_mentor_title"
    t.string   "award_basis",                                 limit: 255
    t.float    "final_decision_weight_ratio",                 limit: 24
    t.boolean  "uses_award_acceptance"
    t.boolean  "enable_award_acceptance"
    t.integer  "accepted_offering_status_id",                 limit: 4
    t.integer  "declined_offering_status_id",                 limit: 4
    t.text     "acceptance_yes_text",                         limit: 65535
    t.text     "acceptance_no_text",                          limit: 65535
    t.text     "acceptance_instructions",                     limit: 65535
    t.string   "acceptance_question1",                        limit: 255
    t.string   "acceptance_question2",                        limit: 255
    t.string   "acceptance_question3",                        limit: 255
    t.integer  "activity_type_id",                            limit: 4
    t.string   "count_method_for_accountability",             limit: 255
    t.integer  "accountability_quarter_id",                   limit: 4
    t.string   "alternate_welcome_page_title",                limit: 255
    t.datetime "mentor_deadline"
    t.boolean  "deny_mentor_access_after_mentor_deadline"
    t.text     "special_requests_text",                       limit: 65535
    t.boolean  "uses_proceedings"
    t.boolean  "uses_lookup"
    t.text     "proceedings_welcome_text",                    limit: 65535
    t.string   "proceedings_pdf_letterhead",                  limit: 255
    t.boolean  "allow_to_review_mentee",                                    default: false
    t.datetime "confirmation_deadline"
    t.boolean  "disable_signature"
  end

  create_table "omsfa_student_info", force: :cascade do |t|
    t.integer  "person_id",         limit: 4
    t.string   "alt_email",         limit: 255
    t.string   "current_address",   limit: 255
    t.string   "current_city",      limit: 255
    t.string   "current_state",     limit: 255
    t.string   "current_zip",       limit: 255
    t.string   "current_phone",     limit: 255
    t.string   "permanent_address", limit: 255
    t.string   "permanent_city",    limit: 255
    t.string   "permanent_state",   limit: 255
    t.string   "permanent_zip",     limit: 255
    t.string   "permanent_phone",   limit: 255
    t.string   "parent_firstname",  limit: 255
    t.string   "parent_lastname",   limit: 255
    t.string   "parent_email",      limit: 255
    t.string   "parent2_firstname", limit: 255
    t.string   "parent2_lastname",  limit: 255
    t.string   "parent2_email",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "open_id_authentication_associations", force: :cascade do |t|
    t.integer "issued",     limit: 4
    t.integer "lifetime",   limit: 4
    t.string  "handle",     limit: 255
    t.string  "assoc_type", limit: 255
    t.binary  "server_url", limit: 65535
    t.binary  "secret",     limit: 65535
  end

  create_table "open_id_authentication_nonces", force: :cascade do |t|
    t.integer "timestamp",  limit: 4,                null: false
    t.string  "server_url", limit: 255
    t.string  "salt",       limit: 255, default: "", null: false
  end

  create_table "organization_contact_units", force: :cascade do |t|
    t.integer "organization_contact_id", limit: 4, null: false
    t.integer "unit_id",                 limit: 4, null: false
    t.boolean "primary_contact"
  end

  add_index "organization_contact_units", ["organization_contact_id"], name: "organization_contact_id", using: :btree
  add_index "organization_contact_units", ["unit_id"], name: "unit_id", using: :btree

  create_table "organization_contacts", force: :cascade do |t|
    t.integer  "person_id",                        limit: 4
    t.integer  "organization_id",                  limit: 4
    t.boolean  "americorps"
    t.date     "americorps_term_end_date"
    t.boolean  "service_learning_contact"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                       limit: 4
    t.integer  "updater_id",                       limit: 4
    t.boolean  "primary_service_learning_contact"
    t.boolean  "current",                                        default: true
    t.boolean  "pipeline_contact"
    t.text     "note",                             limit: 65535
  end

  create_table "organization_migrations", id: false, force: :cascade do |t|
    t.integer "id",                 limit: 4
    t.string  "name",               limit: 255
    t.string  "address1",           limit: 255
    t.string  "address2",           limit: 255
    t.string  "city",               limit: 255
    t.string  "state",              limit: 255
    t.string  "zip",                limit: 255
    t.string  "contact1_name",      limit: 255
    t.string  "contact1_title",     limit: 255
    t.string  "contact1_phone",     limit: 255
    t.string  "contact1_extension", limit: 255
    t.string  "contact1_fax",       limit: 255
    t.string  "contact1_email",     limit: 255
    t.string  "contact2_name",      limit: 255
    t.string  "contact2_phone",     limit: 255
    t.string  "contact2_email",     limit: 255
    t.text    "overview",           limit: 16777215
    t.text    "site_notes",         limit: 16777215
    t.string  "url",                limit: 255
  end

  create_table "organization_quarter_status_types", force: :cascade do |t|
    t.string   "title",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",      limit: 4
    t.integer  "updater_id",      limit: 4
    t.integer  "sequence",        limit: 4
    t.string   "abbreviation",    limit: 255
    t.boolean  "hide_by_default"
  end

  create_table "organization_quarter_statuses", force: :cascade do |t|
    t.integer  "organization_quarter_id",             limit: 4
    t.integer  "organization_quarter_status_type_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                          limit: 4
    t.integer  "updater_id",                          limit: 4
  end

  add_index "organization_quarter_statuses", ["organization_quarter_id"], name: "index_quarter_status_on_org_quarter_id", using: :btree

  create_table "organization_quarters", force: :cascade do |t|
    t.integer  "organization_id",             limit: 4
    t.integer  "quarter_id",                  limit: 4
    t.boolean  "active"
    t.integer  "staff_contact_user_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
    t.boolean  "allow_position_edits"
    t.boolean  "allow_evals"
    t.integer  "unit_id",                     limit: 4
    t.integer  "in_progress_positions_count", limit: 4
    t.integer  "pending_positions_count",     limit: 4
    t.integer  "approved_positions_count",    limit: 4
    t.boolean  "finished_evaluation"
  end

  add_index "organization_quarters", ["organization_id"], name: "index_organization_quarters_on_organization_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "name",                                limit: 255
    t.integer  "default_location_id",                 limit: 4
    t.integer  "parent_organization_id",              limit: 4
    t.string   "mailing_line_1",                      limit: 255
    t.string   "mailing_line_2",                      limit: 255
    t.string   "mailing_city",                        limit: 255
    t.string   "mailing_state",                       limit: 255
    t.string   "mailing_zip",                         limit: 255
    t.string   "website_url",                         limit: 255
    t.string   "main_phone",                          limit: 255
    t.text     "mission_statement",                   limit: 65535
    t.boolean  "approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                          limit: 4
    t.integer  "updater_id",                          limit: 4
    t.integer  "primary_service_learning_contact_id", limit: 4
    t.boolean  "inactive"
    t.integer  "next_active_quarter_id",              limit: 4
    t.boolean  "archive"
    t.boolean  "does_service_learning"
    t.string   "type",                                limit: 255
    t.integer  "school_type_id",                      limit: 4
    t.boolean  "target_school"
    t.boolean  "does_pipeline"
    t.boolean  "multiple_quarter"
  end

  create_table "people", force: :cascade do |t|
    t.string   "firstname",                                        limit: 255
    t.string   "lastname",                                         limit: 255
    t.string   "type",                                             limit: 255
    t.integer  "system_key",                                       limit: 4
    t.integer  "student_no",                                       limit: 4
    t.integer  "est_grad_qtr",                                     limit: 4
    t.string   "nickname",                                         limit: 255
    t.integer  "department_id",                                    limit: 4
    t.string   "email",                                            limit: 255
    t.string   "phone",                                            limit: 255
    t.string   "token",                                            limit: 255
    t.string   "salutation",                                       limit: 255
    t.integer  "extension",                                        limit: 4
    t.string   "address1",                                         limit: 255
    t.string   "address2",                                         limit: 255
    t.string   "address3",                                         limit: 255
    t.string   "city",                                             limit: 255
    t.string   "state",                                            limit: 255
    t.string   "zip",                                              limit: 255
    t.string   "organization",                                     limit: 255
    t.string   "title",                                            limit: 255
    t.datetime "contact_info_updated_at"
    t.string   "gender",                                           limit: 255
    t.string   "other_department",                                 limit: 255
    t.string   "box_no",                                           limit: 255
    t.integer  "creator_id",                                       limit: 4
    t.integer  "updater_id",                                       limit: 4
    t.integer  "deleter_id",                                       limit: 4
    t.datetime "service_learning_risk_date"
    t.string   "service_learning_risk_signature",                  limit: 255
    t.integer  "service_learning_risk_placement_id",               limit: 4
    t.datetime "service_learning_risk_paper_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fax",                                              limit: 255
    t.string   "fullname",                                         limit: 255
    t.datetime "sdb_update_at"
    t.text     "address_block",                                    limit: 65535
    t.integer  "institution_id",                                   limit: 4
    t.string   "major_1",                                          limit: 255
    t.string   "major_2",                                          limit: 255
    t.string   "major_3",                                          limit: 255
    t.integer  "class_standing_id",                                limit: 4
    t.string   "award_ids",                                        limit: 255
    t.datetime "pipeline_orientation"
    t.datetime "pipeline_background_check"
    t.datetime "equipment_reservation_restriction_until"
    t.datetime "equipment_reservation_non_student_override_until"
    t.string   "institution_name",                                 limit: 255
    t.boolean  "pipeline_inactive"
    t.string   "reg_id",                                           limit: 255
    t.boolean  "service_learning_risk_date_extention"
    t.datetime "service_learning_moa_date"
  end

  add_index "people", ["email"], name: "index_people_on_email", using: :btree
  add_index "people", ["student_no"], name: "index_people_on_student_no", using: :btree
  add_index "people", ["system_key"], name: "index_people_on_system_key", using: :btree

  create_table "pipeline_course_filters", force: :cascade do |t|
    t.integer "service_learning_course_id", limit: 4
    t.text    "filters",                    limit: 65535
  end

  create_table "pipeline_positions_favorites", force: :cascade do |t|
    t.integer "person_id",                  limit: 4
    t.integer "pipeline_position_id",       limit: 4
    t.integer "service_learning_course_id", limit: 4
  end

  create_table "pipeline_positions_grade_levels", force: :cascade do |t|
    t.string "name",        limit: 255
    t.text   "description", limit: 65535
  end

  create_table "pipeline_positions_grade_levels_links", force: :cascade do |t|
    t.integer "pipeline_position_id",              limit: 4
    t.integer "pipeline_positions_grade_level_id", limit: 4
  end

  create_table "pipeline_positions_subjects", force: :cascade do |t|
    t.string "name",        limit: 255
    t.text   "description", limit: 65535
  end

  create_table "pipeline_positions_subjects_links", force: :cascade do |t|
    t.integer "pipeline_position_id",          limit: 4
    t.integer "pipeline_positions_subject_id", limit: 4
  end

  create_table "pipeline_positions_tutoring_types", force: :cascade do |t|
    t.string "name",        limit: 255
    t.text   "description", limit: 65535
  end

  create_table "pipeline_positions_tutoring_types_links", force: :cascade do |t|
    t.integer "pipeline_position_id",                limit: 4
    t.integer "pipeline_positions_tutoring_type_id", limit: 4
  end

  create_table "pipeline_student_info", force: :cascade do |t|
    t.integer "person_id",         limit: 4
    t.text    "how_did_you_hear",  limit: 65535
    t.boolean "fulfill_mit"
    t.string  "pursue_els",        limit: 255
    t.string  "teaching_career",   limit: 255
    t.boolean "apply_masters"
    t.boolean "current_els_minor"
  end

  create_table "pipeline_student_types", force: :cascade do |t|
    t.string "name",        limit: 255
    t.text   "description", limit: 65535
  end

  create_table "pipeline_tutoring_logs", force: :cascade do |t|
    t.integer  "service_learning_placement_id", limit: 4
    t.decimal  "hours",                                   precision: 10, scale: 2
    t.date     "log_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "population_conditions", force: :cascade do |t|
    t.integer  "population_id",  limit: 4
    t.string   "attribute_name", limit: 255
    t.string   "eval_method",    limit: 255
    t.text     "value",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "population_group_members", force: :cascade do |t|
    t.integer  "population_group_id",       limit: 4
    t.integer  "population_groupable_id",   limit: 4
    t.string   "population_groupable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "population_groups", force: :cascade do |t|
    t.string   "title",        limit: 255
    t.text     "description",  limit: 65535
    t.integer  "creator_id",   limit: 4
    t.integer  "updater_id",   limit: 4
    t.string   "access_level", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "populations", force: :cascade do |t|
    t.string   "title",                 limit: 255
    t.text     "description",           limit: 65535
    t.string   "populatable_type",      limit: 255
    t.integer  "populatable_id",        limit: 4
    t.string   "starting_set",          limit: 255
    t.string   "condition_operator",    limit: 255
    t.string   "access_level",          limit: 255
    t.integer  "creator_id",            limit: 4
    t.integer  "updater_id",            limit: 4
    t.string   "type",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "object_ids",            limit: 16777215
    t.datetime "objects_generated_at"
    t.integer  "objects_count",         limit: 4
    t.text     "output_fields",         limit: 65535
    t.boolean  "system"
    t.integer  "conditions_counter",    limit: 4
    t.text     "custom_query",          limit: 65535
    t.string   "result_variant",        limit: 255
    t.text     "custom_result_variant", limit: 65535
    t.boolean  "deleted"
    t.datetime "deleted_at"
  end

  create_table "potential_course_organization_match_for_quarters", force: :cascade do |t|
    t.integer  "organization_quarter_id",    limit: 4
    t.integer  "service_learning_course_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                 limit: 4
    t.integer  "updater_id",                 limit: 4
  end

  create_table "potential_course_organization_match_instructor_comments", force: :cascade do |t|
    t.integer  "service_learning_course_instructor_id", limit: 4
    t.integer  "organization_quarter_id",               limit: 4
    t.text     "comment",                               limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "proceedings_favorites", force: :cascade do |t|
    t.integer  "user_id",                     limit: 4
    t.integer  "application_for_offering_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "session_id",                  limit: 255
  end

  add_index "proceedings_favorites", ["session_id"], name: "index_proceedings_favorites_on_session_id", using: :btree
  add_index "proceedings_favorites", ["user_id"], name: "index_proceedings_favorites_on_user_id", using: :btree

  create_table "quarter_codes", force: :cascade do |t|
    t.string  "abbreviation", limit: 255
    t.string  "name",         limit: 255
    t.integer "creator_id",   limit: 4
    t.integer "updater_id",   limit: 4
    t.integer "deleter_id",   limit: 4
  end

  create_table "quarters", force: :cascade do |t|
    t.integer  "year",                limit: 4
    t.date     "first_day"
    t.date     "last_day"
    t.date     "registration_begins"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "quarter_code_id",     limit: 4
    t.integer  "creator_id",          limit: 4
    t.integer  "updater_id",          limit: 4
    t.integer  "deleter_id",          limit: 4
  end

  create_table "quotes", force: :cascade do |t|
    t.string   "key",           limit: 255
    t.string   "quotable_type", limit: 255
    t.integer  "quotable_id",   limit: 4
    t.text     "quote",         limit: 65535
    t.string   "author",        limit: 255
    t.string   "author_title",  limit: 255
    t.string   "picture",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "research_areas", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "research_opportunities", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "email",          limit: 255
    t.string   "department",     limit: 255
    t.string   "title",          limit: 255
    t.text     "description",    limit: 65535
    t.text     "requirements",   limit: 65535
    t.integer  "research_area1", limit: 4
    t.integer  "research_area2", limit: 4
    t.integer  "research_area3", limit: 4
    t.integer  "research_area4", limit: 4
    t.date     "end_date"
    t.boolean  "active"
    t.boolean  "removed"
    t.boolean  "submitted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rights", force: :cascade do |t|
    t.string  "name",       limit: 255
    t.string  "controller", limit: 255
    t.string  "action",     limit: 255
    t.integer "creator_id", limit: 4
    t.integer "updater_id", limit: 4
    t.integer "deleter_id", limit: 4
  end

  create_table "rights_roles", id: false, force: :cascade do |t|
    t.integer "right_id",   limit: 4
    t.integer "role_id",    limit: 4
    t.integer "creator_id", limit: 4
    t.integer "updater_id", limit: 4
    t.integer "deleter_id", limit: 4
  end

  create_table "roles", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.integer "creator_id",  limit: 4
    t.integer "updater_id",  limit: 4
    t.integer "deleter_id",  limit: 4
    t.text    "description", limit: 65535
  end

  create_table "school_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "service_learning_course_courses", force: :cascade do |t|
    t.integer  "service_learning_course_id", limit: 4
    t.integer  "ts_year",                    limit: 4
    t.integer  "ts_quarter",                 limit: 4
    t.integer  "course_branch",              limit: 4
    t.integer  "course_no",                  limit: 4
    t.string   "dept_abbrev",                limit: 255
    t.string   "section_id",                 limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                 limit: 4
    t.integer  "updater_id",                 limit: 4
  end

  create_table "service_learning_course_extra_enrollees", force: :cascade do |t|
    t.integer  "service_learning_course_id", limit: 4
    t.integer  "person_id",                  limit: 4
    t.integer  "creator_id",                 limit: 4
    t.integer  "updater_id",                 limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_learning_course_extra_enrollees", ["person_id"], name: "index_enrollees_on_person_id", using: :btree

  create_table "service_learning_course_instructors", force: :cascade do |t|
    t.integer  "service_learning_course_id", limit: 4
    t.integer  "person_id",                  limit: 4
    t.boolean  "ta"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                 limit: 4
    t.integer  "updater_id",                 limit: 4
    t.text     "note",                       limit: 65535
    t.text     "comment",                    limit: 65535
  end

  create_table "service_learning_course_status_types", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id", limit: 4
    t.integer  "updater_id", limit: 4
  end

  create_table "service_learning_course_statuses", force: :cascade do |t|
    t.integer  "service_learning_course_id",             limit: 4
    t.integer  "service_learning_course_status_type_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                             limit: 4
    t.integer  "updater_id",                             limit: 4
  end

  create_table "service_learning_courses", force: :cascade do |t|
    t.string   "alternate_title",          limit: 255
    t.string   "quarter_id",               limit: 255
    t.string   "syllabus",                 limit: 255
    t.string   "syllabus_url",             limit: 255
    t.text     "overview",                 limit: 65535
    t.text     "role_of_service_learning", limit: 65535
    t.text     "assignments",              limit: 65535
    t.datetime "presentation_time"
    t.integer  "presentation_length",      limit: 4
    t.boolean  "finalized"
    t.datetime "registration_open_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",               limit: 4
    t.integer  "updater_id",               limit: 4
    t.integer  "unit_id",                  limit: 4
    t.text     "students",                 limit: 65535
    t.boolean  "no_filters"
    t.integer  "pipeline_student_type_id", limit: 4
    t.boolean  "required",                               default: false
    t.boolean  "general_study"
  end

  create_table "service_learning_orientations", force: :cascade do |t|
    t.datetime "start_time"
    t.integer  "location_id",                    limit: 4
    t.boolean  "flexible"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                     limit: 4
    t.integer  "updater_id",                     limit: 4
    t.text     "notes",                          limit: 65535
    t.boolean  "different_orientation_contact"
    t.integer  "organization_contact_id",        limit: 4
    t.boolean  "different_orientation_location"
  end

  create_table "service_learning_placements", force: :cascade do |t|
    t.integer  "person_id",                    limit: 4
    t.integer  "service_learning_position_id", limit: 4
    t.integer  "service_learning_course_id",   limit: 4
    t.datetime "waiver_date"
    t.string   "waiver_signature",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
    t.datetime "confirmed_at"
    t.integer  "confirmation_history_id",      limit: 4
    t.integer  "quarter_update_history_id",    limit: 4
    t.integer  "unit_id",                      limit: 4
    t.datetime "tutoring_submitted_at"
  end

  add_index "service_learning_placements", ["person_id"], name: "index_service_learning_placements_on_person_id", using: :btree
  add_index "service_learning_placements", ["service_learning_course_id"], name: "index_placements_on_course_id", using: :btree
  add_index "service_learning_placements", ["service_learning_position_id"], name: "index_placements_on_position_id", using: :btree

  create_table "service_learning_position_shares", force: :cascade do |t|
    t.integer  "unit_id",                      limit: 4
    t.integer  "service_learning_position_id", limit: 4
    t.boolean  "allow_edit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "service_learning_position_times", force: :cascade do |t|
    t.integer  "service_learning_position_id", limit: 4
    t.time     "start_time"
    t.time     "end_time"
    t.boolean  "flexible"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
  end

  add_index "service_learning_position_times", ["service_learning_position_id"], name: "index_times_on_position_id", using: :btree

  create_table "service_learning_position_times_bak", force: :cascade do |t|
    t.integer  "service_learning_position_id", limit: 4
    t.time     "start_time"
    t.time     "end_time"
    t.boolean  "flexible"
    t.boolean  "monday"
    t.boolean  "tuesday"
    t.boolean  "wednesday"
    t.boolean  "thursday"
    t.boolean  "friday"
    t.boolean  "saturday"
    t.boolean  "sunday"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
  end

  create_table "service_learning_positions", force: :cascade do |t|
    t.string   "title",                                 limit: 255
    t.integer  "organization_quarter_id",               limit: 4
    t.integer  "location_id",                           limit: 4
    t.text     "description",                           limit: 65535
    t.string   "age_requirement",                       limit: 255
    t.string   "duration_requirement",                  limit: 255
    t.text     "alternate_transportation",              limit: 65535
    t.integer  "previous_service_learning_position_id", limit: 4
    t.integer  "supervisor_person_id",                  limit: 4
    t.text     "time_notes",                            limit: 65535
    t.integer  "service_learning_orientation_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                            limit: 4
    t.integer  "updater_id",                            limit: 4
    t.boolean  "self_placement"
    t.boolean  "approved"
    t.text     "context_description",                   limit: 65535
    t.text     "impact_description",                    limit: 65535
    t.text     "skills_requirement",                    limit: 65535
    t.integer  "ideal_number_of_slots",                 limit: 4
    t.boolean  "background_check_required"
    t.boolean  "tb_test_required"
    t.text     "paperwork_requirement",                 limit: 65535
    t.string   "time_commitment_requirement",           limit: 255
    t.boolean  "in_progress"
    t.boolean  "times_are_flexible"
    t.text     "other_age_requirement",                 limit: 65535
    t.text     "other_duration_requirement",            limit: 65535
    t.integer  "bus_trip_time",                         limit: 4
    t.integer  "unit_id",                               limit: 4
    t.boolean  "use_slots"
    t.integer  "filled_placements_count",               limit: 4
    t.integer  "total_placements_count",                limit: 4
    t.integer  "unallocated_placements_count",          limit: 4
    t.boolean  "general_study"
    t.text     "learning_goals",                        limit: 65535
    t.text     "academic_topics",                       limit: 65535
    t.text     "sources",                               limit: 65535
    t.boolean  "public_service"
    t.integer  "total_hours",                           limit: 4
    t.integer  "credit",                                limit: 4
    t.integer  "volunteer",                             limit: 4
    t.decimal  "compensation",                                        precision: 8, scale: 2
    t.boolean  "flu_vaccination_required"
    t.boolean  "food_permit_required"
    t.boolean  "other_health_required"
    t.string   "other_health_requirement",              limit: 255
    t.boolean  "legal_name_required"
    t.boolean  "birthdate_required"
    t.boolean  "ssn_required"
    t.boolean  "fingerprint_required"
    t.boolean  "other_background_check_required"
    t.string   "other_background_check_requirement",    limit: 255
    t.boolean  "non_intl_student_required"
    t.date     "volunteer_since"
    t.boolean  "paid"
    t.boolean  "religious"
  end

  add_index "service_learning_positions", ["organization_quarter_id"], name: "index_service_learning_positions_on_organization_quarter_id", using: :btree

  create_table "service_learning_positions_skill_types", force: :cascade do |t|
    t.integer  "service_learning_position_id", limit: 4
    t.integer  "skill_type_id",                limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
  end

  create_table "service_learning_positions_social_issue_types", force: :cascade do |t|
    t.integer  "service_learning_position_id", limit: 4
    t.integer  "social_issue_type_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                   limit: 4
    t.integer  "updater_id",                   limit: 4
  end

  create_table "service_learning_self_placements", force: :cascade do |t|
    t.integer  "person_id",                      limit: 4
    t.integer  "service_learning_placement_id",  limit: 4
    t.integer  "service_learning_position_id",   limit: 4
    t.integer  "service_learning_course_id",     limit: 4
    t.integer  "quarter_id",                     limit: 4
    t.string   "organization_id",                limit: 255
    t.string   "organization_mailing_line_1",    limit: 255
    t.string   "organization_mailing_line_2",    limit: 255
    t.string   "organization_mailing_city",      limit: 255
    t.string   "organization_mailing_state",     limit: 255
    t.string   "organization_mailing_zip",       limit: 255
    t.string   "organization_website_url",       limit: 255
    t.string   "organization_contact_person",    limit: 255
    t.string   "organization_contact_phone",     limit: 255
    t.string   "organization_contact_title",     limit: 255
    t.string   "organization_contact_email",     limit: 255
    t.text     "organization_mission_statement", limit: 65535
    t.text     "hope_to_learn",                  limit: 65535
    t.boolean  "new_organization"
    t.boolean  "submitted"
    t.boolean  "faculty_approved"
    t.text     "faculty_feedback",               limit: 65535
    t.boolean  "admin_approved"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "faculty_person_id",              limit: 255
    t.string   "faculty_firstname",              limit: 255
    t.string   "faculty_lastname",               limit: 255
    t.string   "faculty_email",                  limit: 255
    t.string   "faculty_dept",                   limit: 255
    t.string   "faculty_phone",                  limit: 255
    t.boolean  "general_study",                                default: false, null: false
    t.boolean  "supervisor_approved"
    t.text     "supervisor_feedback",            limit: 65535
    t.datetime "general_study_risk_date"
    t.string   "general_study_risk_signature",   limit: 255
    t.integer  "register_person_id",             limit: 4
    t.datetime "registered_at"
    t.text     "admin_feedback",                 limit: 65535
  end

  create_table "session_histories", force: :cascade do |t|
    t.string   "session_id",     limit: 255
    t.string   "request_uri",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "request_method", limit: 255
  end

  add_index "session_histories", ["session_id"], name: "session_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,        default: "", null: false
    t.text     "data",       limit: 4294967295
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "skill_types", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id", limit: 4
    t.integer  "updater_id", limit: 4
  end

  create_table "social_issue_types", force: :cascade do |t|
    t.string   "title",                       limit: 255
    t.integer  "parent_social_issue_type_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                  limit: 4
    t.integer  "updater_id",                  limit: 4
  end

  create_table "text_templates", force: :cascade do |t|
    t.text     "body",             limit: 65535
    t.string   "name",             limit: 255
    t.string   "subject",          limit: 255
    t.string   "from",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",       limit: 4
    t.integer  "updater_id",       limit: 4
    t.integer  "deleter_id",       limit: 4
    t.string   "target_recipient", limit: 255
    t.string   "type",             limit: 255
    t.string   "margins",          limit: 255
    t.string   "font",             limit: 255
    t.boolean  "lock_name"
  end

  create_table "tokens", force: :cascade do |t|
    t.integer  "tokenable_id",   limit: 4
    t.string   "tokenable_type", limit: 255
    t.string   "token",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tokens", ["token"], name: "index_tokens_on_token", using: :btree
  add_index "tokens", ["tokenable_id", "tokenable_type"], name: "index_tokens_on_tokenable", using: :btree

  create_table "units", force: :cascade do |t|
    t.string   "name",                          limit: 255
    t.string   "abbreviation",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",                    limit: 4
    t.integer  "updater_id",                    limit: 4
    t.integer  "deleter_id",                    limit: 4
    t.string   "logo_uri",                      limit: 255
    t.text     "description",                   limit: 65535
    t.string   "home_url",                      limit: 255
    t.string   "engage_url",                    limit: 255
    t.boolean  "show_on_expo_welcome"
    t.string   "logo",                          limit: 255
    t.boolean  "show_on_equipment_reservation"
    t.string   "phone",                         limit: 255
    t.string   "email",                         limit: 255
  end

  create_table "user_email_addresses", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_unit_role_authorizations", force: :cascade do |t|
    t.integer  "user_unit_role_id", limit: 4
    t.string   "authorizable_type", limit: 255
    t.integer  "authorizable_id",   limit: 4
    t.integer  "creator_id",        limit: 4
    t.integer  "updater_id",        limit: 4
    t.integer  "deleter_id",        limit: 4
    t.text     "note",              limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_unit_roles", force: :cascade do |t|
    t.integer "user_id",    limit: 4
    t.integer "role_id",    limit: 4
    t.integer "unit_id",    limit: 4
    t.integer "creator_id", limit: 4
    t.integer "updater_id", limit: 4
    t.integer "deleter_id", limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 255
    t.string   "email",                     limit: 255
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 255
    t.datetime "remember_token_expires_at"
    t.string   "identity_url",              limit: 255
    t.string   "type",                      limit: 255
    t.integer  "person_id",                 limit: 4
    t.string   "token",                     limit: 255
    t.string   "identity_type",             limit: 255
    t.integer  "creator_id",                limit: 4
    t.integer  "updater_id",                limit: 4
    t.integer  "deleter_id",                limit: 4
    t.boolean  "admin"
    t.integer  "default_email_address_id",  limit: 4
    t.datetime "ferpa_reminder_date"
    t.string   "picture",                   limit: 255
  end

  add_index "users", ["identity_type"], name: "identity_type", using: :btree
  add_index "users", ["login"], name: "login", using: :btree
  add_index "users", ["person_id"], name: "index_users_on_person_id", using: :btree

  create_table "users_user_unit_roles", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id", limit: 4
    t.integer  "updater_id", limit: 4
    t.integer  "deleter_id", limit: 4
  end

end
