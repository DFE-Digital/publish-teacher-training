# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_06_20_135618) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "pg_buffercache"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "postgis"
  enable_extension "uuid-ossp"

  create_table "__EFMigrationsHistory", primary_key: "MigrationId", id: { type: :string, limit: 150 }, force: :cascade do |t|
    t.string "ProductVersion", limit: 32, null: false
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
    t.datetime "created_at", precision: nil
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audit_on_created_at"
    t.index ["request_uuid"], name: "index_audit_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "authentication", force: :cascade do |t|
    t.integer "provider", null: false
    t.string "subject_key", null: false
    t.string "authenticable_type", null: false
    t.bigint "authenticable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authenticable_type", "authenticable_id"], name: "index_authentication_on_authenticable"
    t.index ["subject_key"], name: "index_authentication_on_subject_key"
  end

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "candidate", force: :cascade do |t|
    t.string "email_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contact", force: :cascade do |t|
    t.integer "provider_id", null: false
    t.text "type", null: false
    t.text "name"
    t.text "email"
    t.text "telephone"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "permission_given", default: false
    t.index ["provider_id", "type"], name: "index_contact_on_provider_id_and_type", unique: true
    t.index ["provider_id"], name: "index_contact_on_provider_id"
  end

  create_table "course", id: :serial, force: :cascade do |t|
    t.text "course_code"
    t.text "name"
    t.text "profpost_flag"
    t.text "program_type"
    t.integer "qualification", null: false
    t.datetime "start_date", precision: nil
    t.text "study_mode"
    t.integer "provider_id", default: 0, null: false
    t.text "modular"
    t.integer "english"
    t.integer "maths"
    t.integer "science"
    t.datetime "created_at", precision: nil, default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "changed_at", precision: nil, default: -> { "timezone('utc'::text, now())" }, null: false
    t.text "accredited_provider_code"
    t.datetime "discarded_at", precision: nil
    t.string "age_range_in_years"
    t.date "applications_open_from"
    t.boolean "is_send"
    t.string "level"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }, null: false
    t.integer "degree_grade"
    t.boolean "additional_degree_subject_requirements"
    t.string "degree_subject_requirements"
    t.boolean "accept_pending_gcse"
    t.boolean "accept_gcse_equivalency"
    t.boolean "accept_english_gcse_equivalency"
    t.boolean "accept_maths_gcse_equivalency"
    t.boolean "accept_science_gcse_equivalency"
    t.string "additional_gcse_equivalencies"
    t.boolean "can_sponsor_skilled_worker_visa", default: false
    t.boolean "can_sponsor_student_visa", default: false
    t.integer "master_subject_id"
    t.integer "campaign_name"
    t.integer "application_status", default: 0, null: false
    t.jsonb "a_level_subject_requirements", default: []
    t.boolean "accept_pending_a_level"
    t.boolean "accept_a_level_equivalency"
    t.text "additional_a_level_equivalencies"
    t.string "funding", null: false
    t.string "degree_type", default: "postgraduate", null: false
    t.datetime "visa_sponsorship_application_deadline_at"
    t.index ["accredited_provider_code"], name: "index_course_on_accredited_provider_code"
    t.index ["application_status"], name: "index_course_on_application_status"
    t.index ["campaign_name"], name: "index_course_on_campaign_name"
    t.index ["can_sponsor_skilled_worker_visa"], name: "index_course_on_can_sponsor_skilled_worker_visa"
    t.index ["can_sponsor_student_visa"], name: "index_course_on_can_sponsor_student_visa"
    t.index ["changed_at"], name: "index_course_on_changed_at", unique: true
    t.index ["degree_grade"], name: "index_course_on_degree_grade"
    t.index ["discarded_at"], name: "index_course_on_discarded_at"
    t.index ["funding"], name: "index_course_on_funding"
    t.index ["is_send"], name: "index_course_on_is_send"
    t.index ["master_subject_id"], name: "index_course_on_master_subject_id"
    t.index ["program_type"], name: "index_course_on_program_type"
    t.index ["provider_id", "course_code"], name: "IX_course_provider_id_course_code", unique: true
    t.index ["provider_id"], name: "index_course_on_provider_id"
    t.index ["qualification"], name: "index_course_on_qualification"
    t.index ["study_mode"], name: "index_course_on_study_mode"
    t.index ["uuid"], name: "index_courses_unique_uuid", unique: true
  end

  create_table "course_enrichment", id: :serial, force: :cascade do |t|
    t.integer "created_by_user_id"
    t.datetime "created_at", precision: nil, default: -> { "timezone('utc'::text, now())" }, null: false
    t.jsonb "json_data"
    t.datetime "last_published_timestamp_utc", precision: nil
    t.integer "status", null: false
    t.integer "updated_by_user_id"
    t.datetime "updated_at", precision: nil, default: -> { "timezone('utc'::text, now())" }, null: false
    t.integer "course_id", null: false
    t.index ["course_id"], name: "index_course_enrichment_on_course_id"
    t.index ["created_by_user_id"], name: "IX_course_enrichment_created_by_user_id"
    t.index ["updated_by_user_id"], name: "IX_course_enrichment_updated_by_user_id"
  end

  create_table "course_site", id: :serial, force: :cascade do |t|
    t.integer "course_id"
    t.text "publish"
    t.integer "site_id"
    t.text "status"
    t.text "vac_status"
    t.index ["course_id"], name: "IX_course_site_course_id"
    t.index ["publish"], name: "index_course_site_on_publish"
    t.index ["site_id"], name: "IX_course_site_site_id"
    t.index ["status"], name: "index_course_site_on_status"
    t.index ["vac_status"], name: "index_course_site_on_vac_status"
  end

  create_table "course_subject", id: :serial, force: :cascade do |t|
    t.integer "course_id"
    t.integer "subject_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "position"
    t.index ["course_id", "subject_id"], name: "index_course_subject_on_course_id_and_subject_id", unique: true
    t.index ["course_id"], name: "index_course_subject_on_course_id"
    t.index ["subject_id"], name: "index_course_subject_on_subject_id"
  end

  create_table "data_migrations", primary_key: "version", id: :string, force: :cascade do |t|
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "feedback", force: :cascade do |t|
    t.string "ease_of_use"
    t.text "experience"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "financial_incentive", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.string "bursary_amount"
    t.string "early_career_payments"
    t.string "scholarship"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "subject_knowledge_enhancement_course_available", default: false, null: false
    t.index ["subject_id"], name: "index_financial_incentive_on_subject_id"
  end

  create_table "gias_school", force: :cascade do |t|
    t.text "urn", null: false
    t.text "name", null: false
    t.text "type_code"
    t.text "group_code"
    t.text "status_code"
    t.text "phase_code"
    t.text "minimum_age"
    t.text "maximum_age"
    t.text "ukprn"
    t.text "address1", null: false
    t.text "address2"
    t.text "address3"
    t.text "town", null: false
    t.text "county"
    t.text "postcode", null: false
    t.text "website"
    t.text "telephone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.tsvector "searchable"
    t.float "latitude"
    t.float "longitude"
    t.index ["searchable"], name: "index_gias_school_on_searchable", using: :gin
    t.index ["status_code"], name: "index_gias_school_on_status_code", where: "(status_code = '1'::text)"
    t.index ["urn"], name: "index_gias_school_on_urn", unique: true
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
    t.text "contact_name"
    t.text "year_code"
    t.text "provider_code"
    t.text "provider_type"
    t.text "postcode"
    t.text "website"
    t.text "address1"
    t.text "address2"
    t.text "town"
    t.text "email"
    t.text "telephone"
    t.integer "region_code"
    t.datetime "created_at", precision: nil, default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "changed_at", precision: nil, default: -> { "timezone('utc'::text, now())" }, null: false
    t.integer "recruitment_cycle_id", null: false
    t.datetime "discarded_at", precision: nil
    t.text "train_with_us"
    t.text "train_with_disability"
    t.float "latitude"
    t.float "longitude"
    t.string "ukprn"
    t.string "urn"
    t.boolean "can_sponsor_skilled_worker_visa", default: false
    t.boolean "can_sponsor_student_visa", default: false
    t.string "synonyms", default: [], array: true
    t.integer "accredited_provider_number"
    t.tsvector "searchable"
    t.text "address3"
    t.boolean "selectable_school", default: false, null: false
    t.boolean "accredited", default: false, null: false
    t.index ["accredited"], name: "index_provider_on_accredited"
    t.index ["can_sponsor_student_visa"], name: "index_provider_on_can_sponsor_student_visa"
    t.index ["changed_at"], name: "index_provider_on_changed_at", unique: true
    t.index ["discarded_at"], name: "index_provider_on_discarded_at"
    t.index ["latitude", "longitude"], name: "index_provider_on_latitude_and_longitude"
    t.index ["provider_code"], name: "index_provider_on_provider_code", using: :gin
    t.index ["provider_name"], name: "index_provider_on_provider_name", using: :gin
    t.index ["recruitment_cycle_id", "provider_code"], name: "index_provider_on_recruitment_cycle_id_and_provider_code", unique: true
    t.index ["searchable"], name: "index_provider_on_searchable", using: :gin
    t.index ["synonyms"], name: "index_provider_on_synonyms", using: :gin
  end

  create_table "provider_partnership", force: :cascade do |t|
    t.bigint "accredited_provider_id", null: false
    t.bigint "training_provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accredited_provider_id", "training_provider_id"], name: "idx_on_accredited_provider_id_training_provider_id_7705512e33", unique: true
    t.index ["accredited_provider_id"], name: "index_provider_partnership_on_accredited_provider_id"
    t.index ["training_provider_id"], name: "index_provider_partnership_on_training_provider_id"
  end

  create_table "provider_ucas_preference", force: :cascade do |t|
    t.integer "provider_id", null: false
    t.text "type_of_gt12"
    t.text "send_application_alerts"
    t.text "application_alert_email"
    t.text "gt12_response_destination"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["provider_id"], name: "index_provider_ucas_preference_on_provider_id"
  end

  create_table "recruitment_cycle", force: :cascade do |t|
    t.string "year"
    t.date "application_start_date", null: false
    t.date "application_end_date", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.date "available_in_publish_from"
    t.date "available_for_support_users_from"
  end

  create_table "saved_course", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["candidate_id", "course_id"], name: "index_saved_course_on_candidate_id_and_course_id", unique: true
    t.index ["candidate_id"], name: "index_saved_course_on_candidate_id"
    t.index ["course_id"], name: "index_saved_course_on_course_id"
  end

  create_table "session", force: :cascade do |t|
    t.string "user_agent"
    t.string "ip_address"
    t.string "id_token"
    t.string "session_key", null: false
    t.jsonb "data", default: {}
    t.string "sessionable_type", null: false
    t.bigint "sessionable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_key"], name: "index_session_on_session_key", unique: true
    t.index ["sessionable_type", "sessionable_id"], name: "index_session_on_sessionable"
    t.index ["updated_at"], name: "index_session_on_updated_at"
  end

  create_table "site", id: :serial, force: :cascade do |t|
    t.text "address2"
    t.text "town"
    t.text "address4"
    t.text "code", null: false
    t.text "location_name"
    t.text "postcode"
    t.text "address1"
    t.integer "provider_id", default: 0, null: false
    t.integer "region_code"
    t.datetime "created_at", precision: nil, default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "updated_at", precision: nil, default: -> { "timezone('utc'::text, now())" }, null: false
    t.float "latitude"
    t.float "longitude"
    t.string "urn"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }, null: false
    t.datetime "discarded_at", precision: nil
    t.text "address3"
    t.integer "site_type", default: 0, null: false
    t.index ["discarded_at"], name: "index_site_on_discarded_at"
    t.index ["latitude", "longitude"], name: "index_site_on_latitude_and_longitude"
    t.index ["site_type"], name: "index_site_on_site_type"
    t.index ["uuid"], name: "index_sites_unique_uuid", unique: true
  end

  create_table "statistic", force: :cascade do |t|
    t.jsonb "json_data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_site_placement", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.bigint "site_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_study_site_placement_on_course_id"
    t.index ["site_id"], name: "index_study_site_placement_on_site_id"
  end

  create_table "subject", force: :cascade do |t|
    t.text "type"
    t.text "subject_code"
    t.text "subject_name"
    t.bigint "subject_group_id"
    t.index ["subject_code"], name: "index_subject_on_subject_code"
    t.index ["subject_group_id"], name: "index_subject_on_subject_group_id"
    t.index ["subject_name"], name: "index_subject_on_subject_name"
    t.index ["type"], name: "index_subject_on_type"
  end

  create_table "subject_area", id: false, force: :cascade do |t|
    t.text "typename", null: false
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["typename"], name: "index_subject_area_on_typename", unique: true
  end

  create_table "subject_group", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user", id: :serial, force: :cascade do |t|
    t.text "email"
    t.text "first_name", null: false
    t.text "last_name", null: false
    t.datetime "first_login_date_utc", precision: nil
    t.datetime "last_login_date_utc", precision: nil
    t.text "sign_in_user_id"
    t.datetime "welcome_email_date_utc", precision: nil
    t.datetime "invite_date_utc", precision: nil
    t.datetime "accept_terms_date_utc", precision: nil
    t.string "state"
    t.boolean "admin", default: false
    t.datetime "discarded_at", precision: nil
    t.string "magic_link_token"
    t.datetime "magic_link_token_sent_at", precision: nil
    t.boolean "blazer_access", default: false, null: false
    t.index ["discarded_at"], name: "index_user_on_discarded_at"
    t.index ["email"], name: "IX_user_email", unique: true
  end

  create_table "user_notification", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider_code", null: false
    t.boolean "course_update", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "course_publish", default: false
    t.index ["provider_code"], name: "index_user_notification_on_provider_code"
  end

  create_table "user_permission", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_user_permission_on_provider_id"
    t.index ["user_id", "provider_id"], name: "index_user_permission_on_user_id_and_provider_id", unique: true
    t.index ["user_id"], name: "index_user_permission_on_user_id"
  end

  add_foreign_key "contact", "provider", name: "fk_contact_provider"
  add_foreign_key "course", "provider", name: "FK_course_provider_provider_id", on_delete: :cascade
  add_foreign_key "course_enrichment", "course"
  add_foreign_key "course_enrichment", "user", column: "created_by_user_id", name: "FK_course_enrichment_user_created_by_user_id"
  add_foreign_key "course_enrichment", "user", column: "updated_by_user_id", name: "FK_course_enrichment_user_updated_by_user_id"
  add_foreign_key "course_site", "course", name: "FK_course_site_course_course_id", on_delete: :cascade
  add_foreign_key "course_site", "site", name: "FK_course_site_site_site_id", on_delete: :cascade
  add_foreign_key "course_subject", "course", name: "fk_course_subject__course"
  add_foreign_key "course_subject", "subject", name: "fk_course_subject__subject"
  add_foreign_key "financial_incentive", "subject"
  add_foreign_key "organisation_provider", "organisation", name: "FK_organisation_provider_organisation_organisation_id"
  add_foreign_key "organisation_provider", "provider", name: "FK_organisation_provider_provider_provider_id"
  add_foreign_key "organisation_user", "organisation", name: "FK_organisation_user_organisation_organisation_id"
  add_foreign_key "organisation_user", "user", name: "FK_organisation_user_user_user_id"
  add_foreign_key "provider", "recruitment_cycle"
  add_foreign_key "provider_ucas_preference", "provider", name: "fk_provider_ucas_preference__provider"
  add_foreign_key "saved_course", "candidate"
  add_foreign_key "saved_course", "course"
  add_foreign_key "site", "provider", name: "FK_site_provider_provider_id", on_delete: :cascade
  add_foreign_key "study_site_placement", "course"
  add_foreign_key "study_site_placement", "site"
  add_foreign_key "subject", "subject_area", column: "type", primary_key: "typename", name: "fk_subject__subject_area"
  add_foreign_key "subject", "subject_group"
  add_foreign_key "user_notification", "user"
  add_foreign_key "user_permission", "provider"
  add_foreign_key "user_permission", "user"
end
