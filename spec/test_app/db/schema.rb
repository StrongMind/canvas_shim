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

ActiveRecord::Schema.define(version: 20241114205608) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
  end

  create_table "announcements", force: :cascade do |t|
    t.boolean "pinned"
    t.integer "position"
  end

  create_table "assignment_groups", force: :cascade do |t|
    t.integer "course_id"
    t.float   "group_weight"
    t.string  "name"
    t.integer "context_id"
    t.string  "context_type"
  end

  create_table "assignment_override_students", force: :cascade do |t|
    t.integer  "assignment_id"
    t.integer  "assignment_override_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "assignment_overrides", force: :cascade do |t|
    t.integer  "assignment_id"
    t.datetime "due_at"
    t.string   "title"
    t.boolean  "due_at_overridden"
  end

  create_table "assignments", force: :cascade do |t|
    t.datetime "due_at"
    t.boolean  "published"
    t.integer  "context_id"
    t.integer  "assignment_group_id"
    t.integer  "course_id"
    t.string   "workflow_state"
    t.datetime "updated_at"
    t.boolean  "only_visible_to_overrides"
    t.float    "points_possible"
  end

  create_table "big_blue_button_conferences", force: :cascade do |t|
  end

  create_table "communication_channels", force: :cascade do |t|
    t.string  "path"
    t.string  "path_type"
    t.integer "user_id"
  end

  create_table "content_migrations", force: :cascade do |t|
    t.string  "workflow_state"
    t.integer "context_id"
    t.string  "context_type"
  end

  create_table "content_tags", force: :cascade do |t|
    t.integer "context_module_id"
    t.integer "content_id"
    t.string  "content_type"
    t.integer "assignment_id"
    t.integer "position"
    t.integer "context_id"
    t.string  "context_type"
    t.string  "tag_type"
    t.string  "workflow_state"
  end

  create_table "context_external_tools", force: :cascade do |t|
    t.string  "domain"
    t.integer "course_id"
    t.integer "context_id"
    t.string  "context_type"
    t.string  "consumer_key"
    t.string  "shared_secret"
  end

  create_table "context_module_progressions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "context_module_id"
    t.boolean "collapsed"
    t.integer "lock_version",      default: 0
  end

  create_table "context_modules", force: :cascade do |t|
    t.integer "course_id"
    t.integer "position"
    t.integer "context_id"
    t.string  "context_type"
    t.string  "name"
    t.integer "context_module_progression_id"
    t.text    "completion_requirements"
    t.string  "workflow_state"
  end

  create_table "conversation_batches", force: :cascade do |t|
    t.string "conversation_message_ids"
    t.string "workflow_state"
  end

  create_table "conversation_messages", force: :cascade do |t|
    t.integer  "author_id"
    t.integer  "conversation_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "conversation_participants", force: :cascade do |t|
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "conversation_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.datetime "updated_at"
  end

  create_table "course_sections", force: :cascade do |t|
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "start_at"
    t.string   "time_zone"
    t.datetime "end_at"
    t.datetime "conclude_at"
    t.string   "workflow_state"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",                   default: 0
    t.integer  "attempts",                   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.string   "queue",          limit: 255
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag",            limit: 255
    t.integer  "max_attempts"
    t.string   "strand",         limit: 255
    t.boolean  "next_in_strand",             default: true, null: false
    t.string   "source",         limit: 255
    t.integer  "max_concurrent",             default: 1,    null: false
    t.datetime "expires_at"
    t.index ["locked_by"], name: "index_delayed_jobs_on_locked_by", where: "(locked_by IS NOT NULL)", using: :btree
    t.index ["priority", "run_at", "queue"], name: "get_delayed_jobs_index", where: "((locked_at IS NULL) AND (next_in_strand = true))", using: :btree
    t.index ["run_at", "tag"], name: "index_delayed_jobs_on_run_at_and_tag", using: :btree
    t.index ["strand", "id"], name: "index_delayed_jobs_on_strand", using: :btree
    t.index ["tag"], name: "index_delayed_jobs_on_tag", using: :btree
  end

  create_table "discussion_entries", force: :cascade do |t|
    t.integer "discussion_topic_id"
    t.boolean "unread"
    t.integer "user_id"
    t.integer "parent_id"
  end

  create_table "discussion_topics", force: :cascade do |t|
    t.integer "context_id"
    t.string  "context_type"
    t.integer "assignment_id"
    t.string  "workflow_state"
  end

  create_table "enrollments", force: :cascade do |t|
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "start_at"
    t.string   "type"
    t.integer  "associated_user_id"
    t.string   "workflow_state"
    t.datetime "updated_at"
    t.datetime "last_activity_at"
  end

  create_table "failed_jobs", force: :cascade do |t|
    t.integer  "priority",                       default: 0
    t.integer  "attempts",                       default: 0
    t.string   "handler",         limit: 512000
    t.text     "last_error"
    t.string   "queue",           limit: 255
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tag",             limit: 255
    t.integer  "max_attempts"
    t.string   "strand",          limit: 255
    t.bigint   "original_job_id"
    t.string   "source",          limit: 255
    t.datetime "expires_at"
  end

  create_table "messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "observer_enrollments", force: :cascade do |t|
  end

  create_table "page_views", primary_key: "request_id", force: :cascade do |t|
  end

  create_table "progresses", force: :cascade do |t|
    t.string  "tag"
    t.string  "workflow_state"
    t.integer "course_id"
    t.float   "completion"
  end

  create_table "pseudonyms", force: :cascade do |t|
    t.string   "sis_user_id"
    t.integer  "user_id"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "persistence_token"
    t.string   "single_access_token"
    t.string   "perishable_token"
    t.datetime "created_at"
    t.datetime "last_login_at"
    t.string   "unique_id"
    t.integer  "account_id"
    t.string   "integration_id"
    t.string   "workflow_state"
  end

  create_table "quizzes", force: :cascade do |t|
  end

  create_table "scores", force: :cascade do |t|
    t.string  "workflow_state"
    t.integer "enrollment_id"
    t.integer "current_score"
  end

  create_table "students", force: :cascade do |t|
    t.integer "course_id"
  end

  create_table "submission_comments", force: :cascade do |t|
    t.integer "submission_id"
    t.string  "comment"
    t.bigint  "author_id"
    t.integer "context_id"
    t.string  "context_type"
  end

  create_table "submission_versions", force: :cascade do |t|
    t.text    "yaml"
    t.integer "submission_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.integer  "assignment_id"
    t.integer  "score"
    t.boolean  "excused"
    t.datetime "submitted_at"
    t.string   "workflow_state"
    t.integer  "grade"
    t.integer  "user_id"
    t.datetime "graded_at"
    t.integer  "grader_id"
    t.datetime "cached_due_date"
    t.datetime "updated_at"
    t.string   "context_code"
    t.datetime "created_at"
    t.text     "body"
    t.string   "published_grade"
    t.float    "published_score"
  end

  create_table "user_notes", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "note"
    t.integer  "created_by_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "user_observers", force: :cascade do |t|
    t.integer "user_id",        null: false
    t.integer "observer_id"
    t.string  "workflow_state"
  end

  create_table "users", force: :cascade do |t|
    t.integer  "course_id"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.string   "name"
  end

end
