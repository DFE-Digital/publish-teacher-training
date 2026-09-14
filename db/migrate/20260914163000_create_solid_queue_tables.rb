# frozen_string_literal: true

# Schema from solid_queue 1.7.0 install template (db/queue_schema.rb), without
# foreign keys. FKs are added and validated in follow-up migrations for
# strong_migrations / production safety. Tables stay LOGGED so pending jobs
# survive Postgres restart and HA failover.
class CreateSolidQueueTables < ActiveRecord::Migration[8.1]
  def change
    create_table "solid_queue_blocked_executions" do |t|
      t.bigint "job_id", null: false
      t.string "queue_name", null: false
      t.integer "priority", default: 0, null: false
      t.string "concurrency_key", null: false
      t.datetime "expires_at", null: false
      t.datetime "created_at", null: false

      t.index %w[concurrency_key priority job_id], name: "index_solid_queue_blocked_executions_for_release"
      t.index %w[expires_at concurrency_key], name: "index_solid_queue_blocked_executions_for_maintenance"
      t.index %w[job_id], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
    end

    create_table "solid_queue_claimed_executions" do |t|
      t.bigint "job_id", null: false
      t.bigint "process_id"
      t.datetime "created_at", null: false

      t.index %w[job_id], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
      t.index %w[process_id job_id], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
    end

    create_table "solid_queue_failed_executions" do |t|
      t.bigint "job_id", null: false
      t.text "error"
      t.datetime "created_at", null: false

      t.index %w[job_id], name: "index_solid_queue_failed_executions_on_job_id", unique: true
    end

    create_table "solid_queue_jobs" do |t|
      t.string "queue_name", null: false
      t.string "class_name", null: false
      t.text "arguments"
      t.integer "priority", default: 0, null: false
      t.string "active_job_id"
      t.datetime "scheduled_at"
      t.datetime "finished_at"
      t.string "concurrency_key"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.bigint "batch_id"

      t.index %w[active_job_id], name: "index_solid_queue_jobs_on_active_job_id"
      t.index %w[batch_id], name: "index_solid_queue_jobs_on_batch_id"
      t.index %w[class_name], name: "index_solid_queue_jobs_on_class_name"
      t.index %w[finished_at], name: "index_solid_queue_jobs_on_finished_at"
      t.index %w[queue_name finished_at], name: "index_solid_queue_jobs_for_filtering"
      t.index %w[scheduled_at finished_at], name: "index_solid_queue_jobs_for_alerting"
    end

    create_table "solid_queue_pauses" do |t|
      t.string "queue_name", null: false
      t.datetime "created_at", null: false

      t.index %w[queue_name], name: "index_solid_queue_pauses_on_queue_name", unique: true
    end

    create_table "solid_queue_processes" do |t|
      t.string "kind", null: false
      t.datetime "last_heartbeat_at", null: false
      t.bigint "supervisor_id"
      t.integer "pid", null: false
      t.string "hostname"
      t.text "metadata"
      t.datetime "created_at", null: false
      t.string "name", null: false

      t.index %w[last_heartbeat_at], name: "index_solid_queue_processes_on_last_heartbeat_at"
      t.index %w[name supervisor_id], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
      t.index %w[supervisor_id], name: "index_solid_queue_processes_on_supervisor_id"
    end

    create_table "solid_queue_ready_executions" do |t|
      t.bigint "job_id", null: false
      t.string "queue_name", null: false
      t.integer "priority", default: 0, null: false
      t.datetime "created_at", null: false

      t.index %w[job_id], name: "index_solid_queue_ready_executions_on_job_id", unique: true
      t.index %w[priority job_id], name: "index_solid_queue_poll_all"
      t.index %w[queue_name priority job_id], name: "index_solid_queue_poll_by_queue"
    end

    create_table "solid_queue_recurring_executions" do |t|
      t.bigint "job_id", null: false
      t.string "task_key", null: false
      t.datetime "run_at", null: false
      t.datetime "created_at", null: false

      t.index %w[job_id], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
      t.index %w[task_key run_at], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
    end

    create_table "solid_queue_recurring_tasks" do |t|
      t.string "key", null: false
      t.string "schedule", null: false
      t.string "command", limit: 2048
      t.string "class_name"
      t.text "arguments"
      t.string "queue_name"
      t.integer "priority", default: 0
      t.boolean "static", default: true, null: false
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false

      t.index %w[key], name: "index_solid_queue_recurring_tasks_on_key", unique: true
      t.index %w[static], name: "index_solid_queue_recurring_tasks_on_static"
    end

    create_table "solid_queue_scheduled_executions" do |t|
      t.bigint "job_id", null: false
      t.string "queue_name", null: false
      t.integer "priority", default: 0, null: false
      t.datetime "scheduled_at", null: false
      t.datetime "created_at", null: false

      t.index %w[job_id], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
      t.index %w[scheduled_at priority job_id], name: "index_solid_queue_dispatch_all"
    end

    create_table "solid_queue_semaphores" do |t|
      t.string "key", null: false
      t.integer "value", default: 1, null: false
      t.datetime "expires_at", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false

      t.index %w[expires_at], name: "index_solid_queue_semaphores_on_expires_at"
      t.index %w[key value], name: "index_solid_queue_semaphores_on_key_and_value"
      t.index %w[key], name: "index_solid_queue_semaphores_on_key", unique: true
    end

    create_table "solid_queue_batches" do |t|
      t.string "active_job_batch_id"
      t.string "description"
      t.text "on_finish"
      t.text "on_success"
      t.text "on_failure"
      t.text "metadata"
      t.integer "total_jobs", default: 0, null: false
      t.integer "completed_jobs", default: 0, null: false
      t.integer "failed_jobs", default: 0, null: false
      t.datetime "enqueued_at"
      t.datetime "finished_at"
      t.datetime "failed_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false

      t.index %w[active_job_batch_id], name: "index_solid_queue_batches_on_active_job_batch_id", unique: true
      t.index %w[finished_at], name: "index_solid_queue_batches_on_finished_at"
    end

    create_table "solid_queue_batch_executions" do |t|
      t.bigint "job_id", null: false
      t.bigint "batch_id", null: false
      t.datetime "created_at", null: false

      t.index %w[job_id], name: "index_solid_queue_batch_executions_on_job_id", unique: true
      t.index %w[batch_id], name: "index_solid_queue_batch_executions_on_batch_id"
    end
  end
end
