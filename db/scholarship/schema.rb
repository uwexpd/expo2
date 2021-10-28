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

ActiveRecord::Schema.define(version: 2021_09_13_181219) do

  create_table "categories", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", limit: 200, default: "", null: false
    t.integer "parent_id", null: false
  end

  create_table "db_pages", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "title", limit: 1000, default: ""
    t.string "path", limit: 1000, default: "", null: false
    t.text "main"
    t.text "sidebar"
    t.datetime "created", null: false
    t.datetime "modified", null: false
    t.string "modified_uwnetid", limit: 200, default: "", null: false
    t.string "allowed_uwnetids", limit: 200
  end

  create_table "disabilities", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", limit: 1000, null: false
  end

  create_table "ethnicities", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", limit: 1000, null: false
  end

  create_table "events", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "uwnetid", limit: 64, null: false
    t.string "title", limit: 1000, default: "", null: false
    t.text "description", null: false
    t.datetime "date_start", null: false
    t.datetime "date_end", null: false
    t.datetime "created", null: false
    t.datetime "modified", null: false
  end

  create_table "hierarchies", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", limit: 1000
    t.string "path", limit: 1000
    t.integer "is_external", limit: 2, default: 0
    t.integer "parent_id", default: 0, null: false
    t.integer "show_in_hierarchy", limit: 2, default: 1
    t.integer "show_sidebar", limit: 2, default: 1
    t.integer "show_breadcrumb", limit: 2, default: 1
    t.integer "rank", default: 10, null: false
    t.integer "is_private", limit: 2, default: 0, null: false
  end

  create_table "notes", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "uwnetid", limit: 64, default: ""
    t.text "title"
    t.text "description", null: false
    t.date "date_start", null: false
    t.date "date_end", null: false
    t.integer "rank", default: 10, null: false
    t.datetime "modified", null: false
  end

  create_table "permissions", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "uwnetid", limit: 1000, null: false
  end

  create_table "scholarship_categories", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "scholarship_id", null: false
    t.index ["category_id"], name: "category_id"
    t.index ["scholarship_id"], name: "scholarship_id"
  end

  create_table "scholarship_deadlines", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "scholarship_id", null: false
    t.text "title", null: false
    t.date "deadline", null: false
    t.integer "is_active", limit: 2, default: 0, null: false
  end

  create_table "scholarship_disabilities", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "scholarship_id", null: false
    t.integer "disability_id", null: false
  end

  create_table "scholarship_ethnicities", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "scholarship_id", null: false
    t.integer "ethnicity_id", null: false
  end

  create_table "scholarship_monthly_deadlines", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "scholarship_id"
    t.text "title"
    t.integer "deadline_month"
    t.boolean "is_active"
  end

  create_table "scholarship_types", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "type_id", null: false
    t.integer "scholarship_id", null: false
  end

  create_table "scholarships", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "uwnetid", limit: 64, default: ""
    t.text "title", null: false
    t.text "description"
    t.text "history"
    t.text "eligibility"
    t.text "procedure"
    t.text "contact_info"
    t.text "service_agreement"
    t.string "website_name", limit: 500, default: ""
    t.string "website_url", limit: 2000, default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "award_amount"
    t.integer "freshman", limit: 2, default: 0, null: false
    t.integer "sophomore", limit: 2, default: 0, null: false
    t.integer "junior", limit: 2, default: 0, null: false
    t.integer "senior", limit: 2, default: 0, null: false
    t.integer "graduate", limit: 2, default: 0, null: false
    t.string "disability", limit: 1000, default: ""
    t.integer "male", limit: 2, default: 0
    t.integer "female", limit: 2, default: 0
    t.string "gpa", limit: 1000, default: ""
    t.integer "us_citizen", limit: 2, default: 0, null: false
    t.integer "permanent_resident", limit: 2, default: 0, null: false
    t.integer "other_visa_status", limit: 2, default: 0, null: false
    t.integer "need_based", limit: 2, default: 0, null: false
    t.string "ethnicity", limit: 1000, default: ""
    t.string "length_of_award", limit: 1000, default: ""
    t.string "num_awards", limit: 1000, default: "0", null: false
    t.integer "is_active", limit: 2, default: 0, null: false
    t.integer "resident", limit: 2, default: 0, null: false
    t.integer "non_resident", limit: 2, default: 0, null: false
    t.integer "is_national", limit: 2, default: 0, null: false
    t.integer "type_id"
    t.string "page_stub", limit: 1000
    t.integer "is_incoming_student", limit: 2, default: 0, null: false
    t.integer "is_departmental", limit: 2, default: 0, null: false
    t.integer "hb_1079", limit: 2, default: 0, null: false
    t.integer "veteran", limit: 2, default: 0, null: false
    t.integer "gap_year", limit: 2, default: 0, null: false
    t.integer "graduate_school", limit: 2, default: 0, null: false
    t.text "blurb"
    t.boolean "fifth_year"
    t.boolean "lgbtqi_community"
    t.index ["title", "description", "history", "eligibility"], name: "text_search_index", type: :fulltext
  end

  create_table "settings", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "key", limit: 1000
    t.string "key_friendly", limit: 1000
    t.text "value"
  end

  create_table "types", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", limit: 1000, default: "", null: false
  end

  create_table "welcome_images", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "url", limit: 2000, null: false
    t.string "title", limit: 1000
    t.text "description"
    t.integer "is_active", limit: 2, default: 1
  end

  create_table "workshop_times", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "uwnetid", limit: 64, default: ""
    t.integer "workshop_id", null: false
    t.datetime "date_start", null: false
    t.datetime "date_end", null: false
    t.string "location", limit: 1000, default: "", null: false
  end

  create_table "workshops", id: :integer, options: "ENGINE=MyISAM DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "uwnetid", limit: 64, default: ""
    t.string "title", limit: 1000, default: "", null: false
    t.text "description"
    t.datetime "modified", null: false
  end

end
