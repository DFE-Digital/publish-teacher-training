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

ActiveRecord::Schema.define(version: 2019_09_13_125905) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_buffercache"
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "__EFMigrationsHistory", primary_key: "MigrationId", id: :string, limit: 150, force: :cascade do |t|
    t.string "ProductVersion", limit: 32, null: false
  end

  create_table "access_request", id: :serial, force: :cascade do |t|
    t.text "email_address"
    t.text "first_name"
    t.text "last_name"
    t.text "organisation"
    t.text "reason"
    t.datetime "request_date_utc", null: false
    t.integer "requester_id"
    t.integer "status", null: false
    t.text "requester_email"
    t.index ["requester_id"], name: "IX_access_request_requester_id"
  end

  create_table "audit", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audit_on_created_at"
    t.index ["request_uuid"], name: "index_audit_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "contact", force: :cascade do |t|
    t.integer "provider_id", null: false
    t.text "type", null: false
    t.text "name"
    t.text "email"
    t.text "telephone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id", "type"], name: "index_contact_on_provider_id_and_type", unique: true
    t.index ["provider_id"], name: "index_contact_on_provider_id"
  end

  create_table "course", id: :serial, force: :cascade do |t|
    t.text "age_range"
    t.text "course_code"
    t.text "name"
    t.text "profpost_flag"
    t.text "program_type"
    t.integer "qualification", null: false
    t.datetime "start_date"
    t.text "study_mode"
    t.integer "accrediting_provider_id"
    t.integer "provider_id", default: 0, null: false
    t.text "modular"
    t.integer "english"
    t.integer "maths"
    t.integer "science"
    t.datetime "created_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "updated_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "changed_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.text "accrediting_provider_code"
    t.datetime "discarded_at"
    t.string "age_range_in_years"
    t.date "applications_open_from"
    t.boolean "is_send", default: false
<<<<<<< HEAD
    t.string "level"
=======
    t.integer "level", default: 0
>>>>>>> [2128] Add level to course via migration
    t.index ["accrediting_provider_code"], name: "index_course_on_accrediting_provider_code"
    t.index ["accrediting_provider_id"], name: "IX_course_accrediting_provider_id"
    t.index ["changed_at"], name: "index_course_on_changed_at", unique: true
    t.index ["discarded_at"], name: "index_course_on_discarded_at"
    t.index ["provider_id", "course_code"], name: "IX_course_provider_id_course_code", unique: true
  end

  create_table "course_enrichment", id: :serial, force: :cascade do |t|
    t.integer "created_by_user_id"
    t.datetime "created_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.text "provider_code", null: false
    t.jsonb "json_data"
    t.datetime "last_published_timestamp_utc"
    t.integer "status", null: false
    t.text "ucas_course_code", null: false
    t.integer "updated_by_user_id"
    t.datetime "updated_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.integer "course_id", null: false
    t.index ["course_id"], name: "index_course_enrichment_on_course_id"
    t.index ["created_by_user_id"], name: "IX_course_enrichment_created_by_user_id"
    t.index ["updated_by_user_id"], name: "IX_course_enrichment_updated_by_user_id"
  end

  create_table "course_site", id: :serial, force: :cascade do |t|
    t.date "applications_accepted_from"
    t.integer "course_id"
    t.text "publish"
    t.integer "site_id"
    t.text "status"
    t.text "vac_status"
    t.index ["course_id"], name: "IX_course_site_course_id"
    t.index ["site_id"], name: "IX_course_site_site_id"
  end

  create_table "course_subject", id: :serial, force: :cascade do |t|
    t.integer "course_id"
    t.integer "subject_id"
    t.index ["course_id"], name: "index_course_subject_on_course_id"
    t.index ["subject_id"], name: "index_course_subject_on_subject_id"
  end

  create_table "course_ucas_subject", id: :serial, force: :cascade do |t|
    t.integer "course_id"
    t.integer "ucas_subject_id"
    t.index ["course_id"], name: "IX_course_subject_course_id"
    t.index ["ucas_subject_id"], name: "IX_course_subject_subject_id"
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "nctl_organisation", id: :serial, force: :cascade do |t|
    t.text "name"
    t.text "nctl_id", null: false
    t.integer "organisation_id"
    t.index ["organisation_id"], name: "IX_nctl_organisation_organisation_id"
  end

  create_table "organisation", id: :serial, force: :cascade do |t|
    t.text "name"
    t.text "org_id"
    t.index ["org_id"], name: "IX_organisation_org_id", unique: true
  end

  create_table "organisation_provider", id: :serial, force: :cascade do |t|
    t.integer "provider_id"
    t.integer "organisation_id"
    t.index ["organisation_id"], name: "IX_organisation_provider_organisation_id"
    t.index ["provider_id"], name: "IX_organisation_provider_provider_id"
  end

  create_table "organisation_user", id: :serial, force: :cascade do |t|
    t.integer "organisation_id"
    t.integer "user_id"
    t.index ["organisation_id", "user_id"], name: "index_organisation_user_on_organisation_id_and_user_id", unique: true
    t.index ["organisation_id"], name: "IX_organisation_user_organisation_id"
    t.index ["user_id"], name: "IX_organisation_user_user_id"
  end

  create_table "provider", id: :serial, force: :cascade do |t|
    t.text "address4"
    t.text "provider_name"
    t.text "scheme_member"
    t.text "contact_name"
    t.text "year_code"
    t.text "provider_code"
    t.text "provider_type"
    t.text "postcode"
    t.text "scitt"
    t.text "url"
    t.text "address1"
    t.text "address2"
    t.text "address3"
    t.text "email"
    t.text "telephone"
    t.integer "region_code"
    t.datetime "created_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "updated_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.text "accrediting_provider"
    t.datetime "last_published_at"
    t.datetime "changed_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.integer "recruitment_cycle_id", null: false
    t.index ["changed_at"], name: "index_provider_on_changed_at", unique: true
    t.index ["last_published_at"], name: "IX_provider_last_published_at"
    t.index ["recruitment_cycle_id", "provider_code"], name: "index_provider_on_recruitment_cycle_id_and_provider_code", unique: true
  end

  create_table "provider_enrichment", id: :serial, force: :cascade do |t|
    t.text "provider_code", null: false
    t.jsonb "json_data"
    t.integer "updated_by_user_id", null: false
    t.datetime "created_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "updated_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.integer "created_by_user_id", null: false
    t.datetime "last_published_at"
    t.integer "status", default: 0, null: false
    t.integer "provider_id", null: false
    t.index ["created_by_user_id"], name: "IX_provider_enrichment_created_by_user_id"
    t.index ["provider_code"], name: "IX_provider_enrichment_provider_code"
    t.index ["provider_id"], name: "index_provider_enrichment_on_provider_id"
    t.index ["updated_by_user_id"], name: "IX_provider_enrichment_updated_by_user_id"
  end

  create_table "provider_ucas_preference", force: :cascade do |t|
    t.integer "provider_id", null: false
    t.text "type_of_gt12"
    t.text "send_application_alerts"
    t.text "application_alert_email"
    t.text "gt12_response_destination"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_ucas_preference_on_provider_id"
  end

  create_table "recruitment_cycle", force: :cascade do |t|
    t.string "year"
    t.date "application_start_date", null: false
    t.date "application_end_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "session", id: :serial, force: :cascade do |t|
    t.text "access_token"
    t.datetime "created_utc", null: false
    t.integer "user_id", null: false
    t.index ["access_token", "created_utc"], name: "IX_session_access_token_created_utc"
    t.index ["user_id"], name: "IX_session_user_id"
  end

  create_table "site", id: :serial, force: :cascade do |t|
    t.text "address2"
    t.text "address3"
    t.text "address4"
    t.text "code", null: false
    t.text "location_name"
    t.text "postcode"
    t.text "address1"
    t.integer "provider_id", default: 0, null: false
    t.integer "region_code"
    t.datetime "created_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "updated_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.index ["provider_id", "code"], name: "IX_site_provider_id_code", unique: true
  end

  create_table "subject", force: :cascade do |t|
    t.text "type"
    t.text "subject_code"
    t.text "subject_name"
  end

  create_table "ucas_subject", id: :serial, force: :cascade do |t|
    t.text "subject_name"
    t.text "subject_code", null: false
    t.index ["subject_code"], name: "AK_subject_subject_code", unique: true
  end

  create_table "user", id: :serial, force: :cascade do |t|
    t.text "email"
    t.text "first_name"
    t.text "last_name"
    t.datetime "first_login_date_utc"
    t.datetime "last_login_date_utc"
    t.text "sign_in_user_id"
    t.datetime "welcome_email_date_utc"
    t.datetime "invite_date_utc"
    t.datetime "accept_terms_date_utc"
    t.string "state", null: false
    t.index ["email"], name: "IX_user_email", unique: true
  end

  add_foreign_key "access_request", "\"user\"", column: "requester_id", name: "FK_access_request_user_requester_id", on_delete: :nullify
  add_foreign_key "course", "provider", column: "accrediting_provider_id", name: "FK_course_provider_accrediting_provider_id"
  add_foreign_key "course", "provider", name: "FK_course_provider_provider_id", on_delete: :cascade
  add_foreign_key "course_enrichment", "\"user\"", column: "created_by_user_id", name: "FK_course_enrichment_user_created_by_user_id"
  add_foreign_key "course_enrichment", "\"user\"", column: "updated_by_user_id", name: "FK_course_enrichment_user_updated_by_user_id"
  add_foreign_key "course_enrichment", "course"
  add_foreign_key "course_site", "course", name: "FK_course_site_course_course_id", on_delete: :cascade
  add_foreign_key "course_site", "site", name: "FK_course_site_site_site_id", on_delete: :cascade
  add_foreign_key "course_ucas_subject", "course", name: "FK_course_subject_course_course_id", on_delete: :cascade
  add_foreign_key "course_ucas_subject", "ucas_subject", name: "FK_course_subject_subject_subject_id", on_delete: :cascade
  add_foreign_key "nctl_organisation", "organisation", name: "FK_nctl_organisation_organisation_organisation_id", on_delete: :cascade
  add_foreign_key "organisation_provider", "organisation", name: "FK_organisation_provider_organisation_organisation_id"
  add_foreign_key "organisation_provider", "provider", name: "FK_organisation_provider_provider_provider_id"
  add_foreign_key "organisation_user", "\"user\"", column: "user_id", name: "FK_organisation_user_user_user_id"
  add_foreign_key "organisation_user", "organisation", name: "FK_organisation_user_organisation_organisation_id"
  add_foreign_key "provider", "recruitment_cycle"
  add_foreign_key "provider_enrichment", "\"user\"", column: "created_by_user_id", name: "FK_provider_enrichment_user_created_by_user_id"
  add_foreign_key "provider_enrichment", "\"user\"", column: "updated_by_user_id", name: "FK_provider_enrichment_user_updated_by_user_id"
  add_foreign_key "provider_enrichment", "provider"
  add_foreign_key "session", "\"user\"", column: "user_id", name: "FK_session_user_user_id", on_delete: :cascade
  add_foreign_key "site", "provider", name: "FK_site_provider_provider_id", on_delete: :cascade
end
