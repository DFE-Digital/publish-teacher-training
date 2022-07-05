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

ActiveRecord::Schema[7.0].define(version: 2022_07_05_072950) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "btree_gin"
  enable_extension "btree_gist"
  enable_extension "citext"
  enable_extension "pg_buffercache"
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "__EFMigrationsHistory", primary_key: "MigrationId", id: { type: :string, limit: 150 }, force: :cascade do |t|
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
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_access_request_on_discarded_at"
    t.index ["requester_id"], name: "IX_access_request_requester_id"
  end

  create_table "allocation", force: :cascade do |t|
    t.bigint "provider_id"
    t.bigint "accredited_body_id"
    t.integer "number_of_places"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "request_type", default: 0
    t.text "accredited_body_code"
    t.text "provider_code"
    t.integer "recruitment_cycle_id"
    t.integer "confirmed_number_of_places"
    t.index ["accredited_body_id"], name: "index_allocation_on_accredited_body_id"
    t.index ["provider_id", "accredited_body_id", "provider_code", "accredited_body_code", "recruitment_cycle_id"], name: "index_allocations_on_uniqueness_of_codes_and_ids", unique: true
    t.index ["provider_id"], name: "index_allocation_on_provider_id"
    t.index ["recruitment_cycle_id", "accredited_body_code", "provider_code"], name: "index_allocation_recruitment_and_codes"
    t.index ["request_type"], name: "index_allocation_on_request_type"
  end

  create_table "allocation_uplift", force: :cascade do |t|
    t.bigint "allocation_id", null: false
    t.integer "uplifts"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["allocation_id"], name: "index_allocation_uplift_on_allocation_id"
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
    t.datetime "start_date"
    t.text "study_mode"
    t.integer "provider_id", default: 0, null: false
    t.text "modular"
    t.integer "english"
    t.integer "maths"
    t.integer "science"
    t.datetime "created_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "updated_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "changed_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.text "accredited_body_code"
    t.datetime "discarded_at"
    t.string "age_range_in_years"
    t.date "applications_open_from"
    t.boolean "is_send", default: false
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
    t.index ["accredited_body_code"], name: "index_course_on_accredited_body_code"
    t.index ["changed_at"], name: "index_course_on_changed_at", unique: true
    t.index ["degree_grade"], name: "index_course_on_degree_grade"
    t.index ["discarded_at"], name: "index_course_on_discarded_at"
    t.index ["is_send"], name: "index_course_on_is_send"
    t.index ["program_type"], name: "index_course_on_program_type"
    t.index ["provider_id", "course_code"], name: "IX_course_provider_id_course_code", unique: true
    t.index ["provider_id"], name: "index_course_on_provider_id"
    t.index ["qualification"], name: "index_course_on_qualification"
    t.index ["study_mode"], name: "index_course_on_study_mode"
    t.index ["uuid"], name: "index_courses_unique_uuid", unique: true
  end

  create_table "course_enrichment", id: :serial, force: :cascade do |t|
    t.integer "created_by_user_id"
    t.datetime "created_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.jsonb "json_data"
    t.datetime "last_published_timestamp_utc"
    t.integer "status", null: false
    t.integer "updated_by_user_id"
    t.datetime "updated_at", default: -> { "timezone('utc'::text, now())" }, null: false
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
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
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
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "financial_incentive", force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.string "bursary_amount"
    t.string "early_career_payments"
    t.string "scholarship"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "subject_knowledge_enhancement_course_available", default: false, null: false
    t.index ["subject_id"], name: "index_financial_incentive_on_subject_id"
  end

  create_table "interrupt_page_acknowledgement", force: :cascade do |t|
    t.string "page", null: false
    t.bigint "recruitment_cycle_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["page", "recruitment_cycle_id", "user_id"], name: "interrupt_page_all_column_idx", unique: true
    t.index ["recruitment_cycle_id"], name: "index_interrupt_page_acknowledgement_on_recruitment_cycle_id"
    t.index ["user_id"], name: "index_interrupt_page_acknowledgement_on_user_id"
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
    t.text "website"
    t.text "address1"
    t.text "address2"
    t.text "address3"
    t.text "email"
    t.text "telephone"
    t.integer "region_code"
    t.datetime "created_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.datetime "updated_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.text "accrediting_provider"
    t.datetime "changed_at", default: -> { "timezone('utc'::text, now())" }, null: false
    t.integer "recruitment_cycle_id", null: false
    t.datetime "discarded_at"
    t.text "train_with_us"
    t.text "train_with_disability"
    t.jsonb "accrediting_provider_enrichments"
    t.float "latitude"
    t.float "longitude"
    t.string "ukprn"
    t.string "urn"
    t.boolean "can_sponsor_skilled_worker_visa"
    t.boolean "can_sponsor_student_visa"
    t.index ["can_sponsor_student_visa"], name: "index_provider_on_can_sponsor_student_visa"
    t.index ["changed_at"], name: "index_provider_on_changed_at", unique: true
    t.index ["discarded_at"], name: "index_provider_on_discarded_at"
    t.index ["latitude", "longitude"], name: "index_provider_on_latitude_and_longitude"
    t.index ["provider_code"], name: "index_provider_on_provider_code", using: :gin
    t.index ["provider_name"], name: "index_provider_on_provider_name", using: :gin
    t.index ["recruitment_cycle_id", "provider_code"], name: "index_provider_on_recruitment_cycle_id_and_provider_code", unique: true
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
    t.float "latitude"
    t.float "longitude"
    t.string "urn"
    t.uuid "uuid", default: -> { "uuid_generate_v4()" }, null: false
    t.datetime "discarded_at"
    t.index ["discarded_at"], name: "index_site_on_discarded_at"
    t.index ["latitude", "longitude"], name: "index_site_on_latitude_and_longitude"
    t.index ["uuid"], name: "index_sites_unique_uuid", unique: true
  end

  create_table "statistic", force: :cascade do |t|
    t.jsonb "json_data", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "subject", force: :cascade do |t|
    t.text "type"
    t.text "subject_code"
    t.text "subject_name"
    t.index ["subject_code"], name: "index_subject_on_subject_code"
    t.index ["subject_name"], name: "index_subject_on_subject_name"
    t.index ["type"], name: "index_subject_on_type"
  end

  create_table "subject_area", id: false, force: :cascade do |t|
    t.text "typename", null: false
    t.text "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["typename"], name: "index_subject_area_on_typename", unique: true
  end

  create_table "user", id: :serial, force: :cascade do |t|
    t.text "email"
    t.text "first_name", null: false
    t.text "last_name", null: false
    t.datetime "first_login_date_utc"
    t.datetime "last_login_date_utc"
    t.text "sign_in_user_id"
    t.datetime "welcome_email_date_utc"
    t.datetime "invite_date_utc"
    t.datetime "accept_terms_date_utc"
    t.string "state"
    t.boolean "admin", default: false
    t.datetime "discarded_at"
    t.string "magic_link_token"
    t.datetime "magic_link_token_sent_at"
    t.index ["discarded_at"], name: "index_user_on_discarded_at"
    t.index ["email"], name: "IX_user_email", unique: true
  end

  create_table "user_notification", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "provider_code", null: false
    t.boolean "course_update", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "course_publish", default: false
    t.index ["provider_code"], name: "index_user_notification_on_provider_code"
  end

  create_table "user_permission", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "provider_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["provider_id"], name: "index_user_permission_on_provider_id"
    t.index ["user_id", "provider_id"], name: "index_user_permission_on_user_id_and_provider_id", unique: true
    t.index ["user_id"], name: "index_user_permission_on_user_id"
  end

  add_foreign_key "access_request", "\"user\"", column: "requester_id", name: "FK_access_request_user_requester_id", on_delete: :nullify
  add_foreign_key "allocation", "provider"
  add_foreign_key "allocation", "provider", column: "accredited_body_id"
  add_foreign_key "allocation_uplift", "allocation"
  add_foreign_key "contact", "provider", name: "fk_contact_provider"
  add_foreign_key "course", "provider", name: "FK_course_provider_provider_id", on_delete: :cascade
  add_foreign_key "course_enrichment", "\"user\"", column: "created_by_user_id", name: "FK_course_enrichment_user_created_by_user_id"
  add_foreign_key "course_enrichment", "\"user\"", column: "updated_by_user_id", name: "FK_course_enrichment_user_updated_by_user_id"
  add_foreign_key "course_enrichment", "course"
  add_foreign_key "course_site", "course", name: "FK_course_site_course_course_id", on_delete: :cascade
  add_foreign_key "course_site", "site", name: "FK_course_site_site_site_id", on_delete: :cascade
  add_foreign_key "course_subject", "course", name: "fk_course_subject__course"
  add_foreign_key "course_subject", "subject", name: "fk_course_subject__subject"
  add_foreign_key "financial_incentive", "subject"
  add_foreign_key "organisation_provider", "organisation", name: "FK_organisation_provider_organisation_organisation_id"
  add_foreign_key "organisation_provider", "provider", name: "FK_organisation_provider_provider_provider_id"
  add_foreign_key "organisation_user", "\"user\"", column: "user_id", name: "FK_organisation_user_user_user_id"
  add_foreign_key "organisation_user", "organisation", name: "FK_organisation_user_organisation_organisation_id"
  add_foreign_key "provider", "recruitment_cycle"
  add_foreign_key "provider_ucas_preference", "provider", name: "fk_provider_ucas_preference__provider"
  add_foreign_key "session", "\"user\"", column: "user_id", name: "FK_session_user_user_id", on_delete: :cascade
  add_foreign_key "site", "provider", name: "FK_site_provider_provider_id", on_delete: :cascade
  add_foreign_key "subject", "subject_area", column: "type", primary_key: "typename", name: "fk_subject__subject_area"
  add_foreign_key "user_notification", "\"user\"", column: "user_id"
  add_foreign_key "user_permission", "\"user\"", column: "user_id"
  add_foreign_key "user_permission", "provider"
end
